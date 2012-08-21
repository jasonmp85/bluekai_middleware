# encoding: UTF-8

require 'spec_helper'

describe BlueKaiMiddleware::HTTPError do
  let(:status) { 401 }
  let(:body)   { 'The credentials were not accepted' }
  subject { described_class.new(status, body) }

  it { should be_kind_of(StandardError) }
  its(:status)  { should eq status }
  its(:body)    { should eq body }
  its(:message) { should eq 'Unauthorized' }

  context 'with an invalid status' do
    let(:status) { -100 }

    # StandardError defaults to the class name as the message
    its(:message) { should eq described_class.to_s }
  end
end
