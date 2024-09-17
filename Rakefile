require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec'
end

RSpec::Core::RakeTask.new(:spec_performance) do |t|
  t.pattern = 'performance'
end

task :default => [:spec, :spec_performance]
