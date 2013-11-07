require 'capybara/rspec'
require 'capybara/poltergeist'
require 'rack/file'
require 'dotenv'

Capybara.app = Rack::File.new('tmp')
Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|
  config.include Capybara::DSL
end

Dotenv.load