# encoding: UTF-8

require 'spec_helper'

describe BlueKaiMiddleware::LogSubscriber do
  let(:name)     { 'CustomName' }
  let(:instance) { described_class.new(name) }
  subject        { instance }

  it { should be_a_kind_of ActiveSupport::LogSubscriber }

  context 'when notified by a faraday request' do
    let(:payload)  { {:method => :get, :url => 'http://example.com'} }
    let(:event)    { ActiveSupport::Notifications::Event.new('request.faraday', 1, 1.5, 'txn_id', payload) }
    let(:logger)   { double('logger') }

    before do
      BlueKaiMiddleware::LogSubscriber.colorize_logging = false
      instance.logger = logger
    end

    it 'should log the name, method, duration, and URL of the request' do
      logger.should_receive(:info).with('  CustomName GET (500.0ms)  http://example.com')

      instance.request(event)
    end
  end
end
