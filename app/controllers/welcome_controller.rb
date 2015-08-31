class WelcomeController < ApplicationController

  # GET /welcome
  def index
    @labs = YAML.load_file(Rails.root.join("config", "labs.yml"))
  end

end
