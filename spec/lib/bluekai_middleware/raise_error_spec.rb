# encoding: UTF-8

require 'spec_helper'

describe BlueKaiMiddleware::RaiseError do
  let(:instance) { described_class.new }
  subject { instance }

  it { should be_a_kind_of Faraday::Response::Middleware }

  describe '#on_complete' do
    let(:response)     { { status: status, body: 'Document body' } }
    let(:on_complete) { instance.on_complete(response) }
    subject { on_complete }

    context 'with a 200 status code' do
      let(:status) { 200 }

      specify { expect {on_complete}.to_not raise_error }
    end

    context 'with a 400 status code' do
      let(:status) { 400 }

      specify { expect {on_complete}.to raise_error(BlueKaiMiddleware::ClientError) }
    end

    context 'with a 500 status code' do
      let(:status) { 500 }

      specify { expect {on_complete}.to raise_error(BlueKaiMiddleware::ServerError) }
    end
  end
end

describe BlueKaiMiddleware::RaiseError::StatusCodeFix do
  let(:instance) { described_class.to_s; described_class.new }
  subject { instance }

  it { should be_a_kind_of Faraday::Response::Middleware }

  describe 'a response passed to #on_complete' do
    let(:response) { { status: status, body: body } }
    subject { response }

    before { instance.on_complete(response) }

    context 'with a 200 status and successful body status' do
      let(:status) { 200 }
      let(:body)   { {'status' => 'QUERY_SUCCESS'} }

      its([:status]) { should eq 200 }
    end

    context 'with a 200 status and non-hash body' do
      let(:status) { 200 }
      let(:body)   { 'Document body' }

      its([:status]) { should eq 200 }
    end

    context 'with a 200 status and no successful body status' do
      let(:status) { 200 }
      let(:body)   { {'status' => 'SOMETHING_BAD'} }

      its([:status]) { should eq 400 }
    end

    context 'with a 500 status and non-hash body' do
      let(:status) { 500 }
      let(:body)   { 'Document body' }

      its([:status]) { should eq 500 }
    end
  end
end
