# encoding: UTF-8

require 'bluekai_middleware'

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
