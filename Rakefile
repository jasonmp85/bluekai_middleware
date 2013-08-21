require 'bundler/gem_tasks'

require 'yard'
YARD::Rake::YardocTask.new(:yard)

require 'rspec/core'
require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'

require 'appraisal'

RSpec::Core::RakeTask.new(:spec) { |t| t.fail_on_error = false }

task :default => :spec

desc "Build for Jenkins, producing artifacts"
task :ci => [
  'ci:clean',
  'ci:setup:rspec',
  'ci:enable_coverage',
  'spec',
  'yard',
  'build'
]

namespace :ci do
  desc "Clean up build artifacts"
  task :clean do
    FileUtils.rm_rf(Dir['doc'])
    FileUtils.rm_rf(Dir['pkg'])
    FileUtils.rm_rf(Dir['spec/reports'])
  end

  desc "Set the SimpleCov flag"
  task(:enable_coverage) { ENV['SCOV'] = 'on' }
end
