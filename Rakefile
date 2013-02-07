require 'bundler/gem_tasks'

require 'yard'
YARD::Rake::YardocTask.new(:yard)

require 'rspec/core'
require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'

RSpec::Core::RakeTask.new(:spec) { |t| t.fail_on_error = false }

task :default => :spec

desc "Build for Jenkins, producing artifacts"
task :ci => [
  'ci:clean',
  'ci:setup:rspec',
#  'spec',
  'coverage:instrumented_specs',
  'yard',
  'build'
]

namespace :ci do
  desc "Clean up build artifacts"
  task :clean do
    FileUtils.rm_rf(Dir['doc'])
    FileUtils.rm_rf(Dir['pkg'])
    FileUtils.rm_rf(Dir['spec/reports'])
    FileUtils.rm_rf(Dir['coverage'])
  end
end

namespace :coverage do
  desc "Run unit tests with SimpleCov"
  task :instrumented_specs do
    require 'simplecov'
    require 'simplecov-rcov'
    SimpleCov.command_name 'wrapup'
    SimpleCov.start 'rails'
    SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter

    %w[lib].each do |path|
      task_name = "coverage:#{File.basename(path)}"

      ENV['SCOV']      = 'on'
      ENV['SCOV_PATH'] = path
      ENV['SCOV_TASK'] = task_name

      Rake::Task[task_name].invoke
    end


    ENV.delete('SCOV')
    ENV.delete('SCOV_PATH')
    ENV.delete('SCOV_TASK')
  end

  [:lib].each do |suite_name|
    # Redefine rspec-rails tasks to not fail on error
    RSpec::Core::RakeTask.new(suite_name) do |t|
      t.fail_on_error = false
      t.pattern = "spec/#{suite_name}/**/*_spec.rb"
    end
  end
end
