source 'https://rubygems.org'
ruby '2.2.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.3'
# Use postgresql as the database for Active Record
gem 'pg'
gem 'rails_12factor', group: :production
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

gem 'puma'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

gem 'sprockets', '~> 3.0'
gem 'sprockets-es6'
gem 'react-rails', '~> 1.0'
gem 'react-bootstrap-rails'
gem 'sprockets-coffee-react'

gem 'lodash-rails'

gem 'bootstrap-sass'
gem 'bootswatch-rails'
gem 'font-awesome-sass', '~> 4.3.0'

source 'https://rails-assets.org' do
  gem 'rails-assets-fluxxor'
  gem 'rails-assets-classnames'
  gem 'rails-assets-react-input-autosize'
  gem 'rails-assets-react-select'
end

group :test do
  gem "webmock", require: "webmock/minitest"
  gem 'shoulda'
  gem "capybara"
  gem "minitest"
  gem "rr"
  gem "minitest-reporters"
  gem 'factory_girl_rails'
end

group :development, :test do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'pry'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'factory-helper'
end
