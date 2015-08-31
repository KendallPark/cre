require 'mechanize'
require 'fileutils'
require 'yaml'
require 'pry'

class Scraper
  URL = "http://accessmedicine.mhmedical.com/content.aspx?bookid=503&sectionid=43474716&jumpsectionID=43474888"
  ROOT_URL = "https://bblearn.missouri.edu"
  # COURSE_SCHEMA = YAML::load_file(File.join(File.dirname(__FILE__), 'courses.yml'))
  # CONFIG = YAML::load_file(File.join(File.dirname(__FILE__), 'config.yml'))
  SAVE_DIR = File.expand_path("../../config/labs.yml", __FILE__)
  # USERNAME = CONFIG["pawprint"]
  # PASSWORD = CONFIG["password"]
  @@mechanize = Mechanize.new

  def self.scrape_acronyms(table)
    acronyms = {}
    table.search("tr").each do |row|
      acronym = row.children.first.text
      definition = row.children.last.text
      acronyms[acronym] = definition
    end
    acronyms
  end

  def self.scrape_labs(tables)
    labs = {}
    tables.each do |table|
      title = table.search(".tableCaption").text
      tds = table.search("tbody td")
      labs[title] = { test: tds[0].children.to_s.gsub("href=\"/", "href=\"//accessmedicine.mhmedical.com/"),
                      basis: tds[1].children.to_s.gsub("href=\"/", "href=\"//accessmedicine.mhmedical.com/"),
                      interpretation: tds[2].children.to_s.gsub("href=\"/", "href=\"//accessmedicine.mhmedical.com/"),
                      comments: tds[3].children.to_s.gsub("href=\"/", "href=\"//accessmedicine.mhmedical.com/") }
    end
    labs
  end

  def self.scrape!(save_dir=SAVE_DIR)
    @@mechanize.get(URL) do |page|
      tables = page.search(".tTable")
      acronyms = scrape_acronyms(tables.first)
      labs = scrape_labs(tables[4..-1])
      data = { acronyms: acronyms, labs: labs }
      File.open(save_dir, 'w') {|f| f.write data.to_yaml }
    end
  end

end

Scraper.scrape!
