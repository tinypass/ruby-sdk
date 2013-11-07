require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new

task :default => :spec
task :test => :spec

desc "Open a pry session preloaded with this library"
task :console do
  sh "pry -I./lib -rtinypass"
end
task :c => :console

desc "Run specs with code coverage"
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task["spec"].execute
end