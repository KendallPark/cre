require 'fileutils'
require 'yaml'
require 'nokogiri'
require 'pry'

class Scraper
  SAVE_DIR = File.expand_path("../../config/pharm.yml", __FILE__)
  PHARM_CARDS = File.expand_path("../pharm.xml", __FILE__)
  HEADERS = ["Actions", "MOA", "Actions & MOA", "Abs/Distrib/Elim", "Clinical use", "Adverse effects", "Special points", "Similar drugs", "Similar drug, ""Drugs with similar action"]

  def self.scrape_front_row(row)
    tds = row.css("td")
    id = tds.first.text
    drug = tds[1].text
    category = tds[2].text
    subcategory = tds[3] && !tds[3].text.empty? ? tds[3].text : nil
    if category.empty? && subcategory && !subcategory.empty?
      category = subcategory
      subcategory = nil
    end
    if category.match /^(.+) \((.+)\)$/
      match = category.match /^(.+) \((.+)\)$/
      category = match[1]
      subcategory = match[2]
    elsif category == "Female Reproductive System"
      category = "Reproductive System"
      subcategory = "Female"
    elsif category == "Male Reproductive System"
      category = "Reproductive System"
      subcategory = "Male"
    elsif category.match /^(.+): (.+)$/
      match = category.match /^(.+): (.+)$/
      category = match[1]
      subcategory = match[2]
    elsif category.match /^(.+) – (.+)$/
      match = category.match /^(.+) – (.+)$/
      category = match[1]
      subcategory = match[2]
    elsif id == '23.01'
      drug = "Chlorpromazine (Thorazine)"
      category = "Antipsychotics"
    end

    { card_id: id, name: drug, category: category, subcategory: subcategory }
  end

  def self.scrape_front(card)
    if card.css("tr").first.css("td").first.text =~ /^\d?\d\.\d\d$/
      data = scrape_front_row(card.css("tr").first)
    elsif card.css("tr")[1].css("td").first.text =~ /^\d?\d\.\d\d$/
      name = card.css("tr").first.css("td")[1].text
      data = scrape_front_row(card.css("tr")[1])
      data[:name] = "#{name} #{data[:name]}" if !name.empty?
      data
    else
      nil
    end
  end

  def self.front_card?(card)
    card.css("tr").first.css("td").first.text =~ /^\d?\d\.\d\d$/ || card.css("tr")[1].css("td").first.text =~ /^\d?\d\.\d\d$/
  end

  def self.scrape_back(card)
    rows = card.css("tr")
    data = {}
    index = 1
    if rows.first.css("td").length == 2
      index = 0
      rows.shift if rows.first.css("td").first.text.empty?
    end
    if rows.first.css("td")[index] && !rows.first.css("td")[index].text.empty?
      data["Class"] = rows.first.css("td")[index].text
      if data["Class"].match(/(.+) \(Similar drug[s]?: (.+)\)$/)
        match = data["Class"].match(/(.+) \(Similar drug[s]?: (.+)\)$/)
        data["Class"] = match[1]
        data["Similar drug(s)"] = match[2].sub(/\.$/, '')
      end
    end
    field = nil
    rows[1...rows.length].each do |row|
      if !row.css("td").first.text.empty? && HEADERS.include?(row.css("td").first.text)
        field = row.css("td").first.text
        field = "Similar drug(s)" if field.match(/^Similar drug[s]?$/)
        data[field] = row.css("td")[1].text.sub(/\.$/, '')
      elsif field && row.css("td")[1] && !row.css("td")[1].text.empty?
        next if row.css("td")[1].text =~ /^RD 7e/
        data[field] += " #{row.css("td")[1].text}"
      else
        field = nil
      end
    end
    data
  end

  def self.scrape!()
    File.open(PHARM_CARDS) do |file|
      xml = Nokogiri::XML(file)
      current = nil
      cards = {}
      xml.xpath("//page")[15..607].each do |card|
        if current
          features = scrape_back(card)
          key = "#{current[:name].downcase}"
          key += " (#{features['Similar drug(s)'].downcase})" if features['Similar drug(s)']
          key += " [#{current[:category].downcase}]"
          cards[key] = current.merge({features: features}) if !features.empty?
          current = nil
        else
          current = scrape_front(card)
        end
      end
      cards = cards.sort.to_h
      File.open(SAVE_DIR, 'w') {|f| f.write cards.to_yaml }
    end

  end

end

Scraper.scrape!
