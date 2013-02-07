# encoding: UTF-8

require 'bluekai_middleware'
require 'simplecov'

if ENV['SCOV']
  # Scope our run by the command name
  SimpleCov.command_name ENV['SCOV_TASK']

  # Find the relevant files
  path = File.join SimpleCov.root, ENV['SCOV_PATH']

  SimpleCov.start 'rails' do
    # Reject irrelevant files
    add_filter { |file| !(file.filename =~ %r/\A#{path}/) }

    merge_timeout 3600
  end
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  RSpec::Matchers.define :be_well_formed do
    failure_message_for_should do |actual|
      actual.join("\n")
    end

    match do |actual|
      actual.empty?
    end
  end
end
