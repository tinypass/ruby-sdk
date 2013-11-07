if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

#require 'bundler/setup'

require 'tinypass'
require 'nokogiri'
require 'pry'
require 'webmock/rspec'

Dir["spec/support/**/*.rb"].each { |f| load f }

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.include TinypassFactories

  config.before(:each) do
    Tinypass.sandbox = true
    Tinypass.aid = "TEST_AID"
    Tinypass.private_key = "thestringliteralisexactlyfortych"
  end
end
