class WelcomeController < ApplicationController

  # GET /welcome
  def index
    @off_campus = params[:off_campus] || params["off_campus"] == "true"
    @labs = YAML.load_file(Rails.root.join("config", "labs.yml"))
    pharm_cards = YAML.load_file(Rails.root.join("config", "pharm.yml"))
    additional_pharm = YAML.load_file(Rails.root.join("config", "additional_pharm.yml"))
    @pharm = pharm_cards.merge(additional_pharm)
  end

end
