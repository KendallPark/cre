class WelcomeController < ApplicationController

  # GET /welcome
  def index
    @off_campus = params["off_campus"] == "true"
    @labs = YAML.load_file(Rails.root.join("config", "labs.yml"))
  end

end
