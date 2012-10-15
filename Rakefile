require "bundler/gem_tasks"

require "rspec/core/rake_task"

desc "Runs all the specs"
task default: %w(spec)

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  # Put spec opts in a file named .rspec in root
end
