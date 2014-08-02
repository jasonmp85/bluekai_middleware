# encoding: UTF-8

require 'spec_helper'

describe BlueKaiMiddleware::Authenticate do
  let(:app)    { double('app') }
  let(:signer) { double('signer') }
  let(:user)   { 'c66ec890601f16fdb53ae29525c9eb12fdc04746' }
  let(:key)    { 'fakekey' }
  let(:private_key) { 'fakesecretkey' }

  let(:instance) { described_class.new(app, user, key) }
  subject { instance }

  describe '#call' do
    describe 'the url parameter' do
      let(:env)       { {url: url} }
      let(:signature) { 'fakesignature' }

      let(:url) do
        Faraday::Connection.new do |faraday|
          faraday.use BlueKaiMiddleware::Authenticate, key, private_key
        end.build_url('https://bluekai.com/Services/Test')
      end
      subject         { url }

      context 'after being processed by the middleware' do
        before do
          BlueKaiMiddleware::Authenticate::SigningContext.should_receive(:new).with(env, key).and_return(signer)
          signer.should_receive(:signature).and_return(signature)

          app.should_receive(:call).with(env)

          instance.call(env)
        end

        its(:query) { should include("bkuid=#{user}") }
        its(:query) { should include("bksig=#{signature}") }
      end
    end
  end
end

describe BlueKaiMiddleware::Authenticate::SigningContext do
  let(:env) do
    {
      method: 'post',
      body:   '{count: 4, data: [1, 2, 3, 4]}',
      path:   '/Services/Test',
      params: params
    }
  end
  let(:key) { 'a0887eca1aa61334449974fe6474671d3f2965c6' }
  let(:params) { { 'secret' => 'secret', 'name' => 'BlueKai Test' } }

  let(:instance) { described_class.new(env, key) }
  subject { instance }

  its(:signature) { should eq 'JfZ2rjdvZzYn183h/WeDluZ43clCONo+LNE7LQjAqBk=' }

  describe '#signature' do
    let(:data) { 'POST/Services/TestBlueKai+Testsecret{count: 4, data: [1, 2, 3, 4]}' }

    it 'should pass the correct data to the digest algorithm' do
      OpenSSL::HMAC.should_receive(:digest)
                   .with(an_instance_of(OpenSSL::Digest), key, data)
                   .and_return('signed_data')

      instance.signature
    end

    context 'with a repeated key in the query string' do
      let(:params) { {'secret' => %w[secret first_secret], 'name' => 'BlueKai Test' } }
      let(:data) { 'POST/Services/TestBlueKai+Testsecretfirst_secret{count: 4, data: [1, 2, 3, 4]}' }

      it 'should pass the correct data to the digest algorithm' do
        OpenSSL::HMAC.should_receive(:digest)
                     .with(an_instance_of(OpenSSL::Digest), key, data)
                     .and_return('signed_data')

        instance.signature
      end
    end
  end
end
