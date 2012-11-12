# encoding: UTF-8

require 'spec_helper'

shared_examples "Faraday version agnostic BK middleware" do
    HOST = 'bluekai.com'
    PATH = '/Services/Test'

  describe BlueKaiMiddleware::Authenticate do
    let(:app)    { double('app') }
    let(:signer) { double('signer') }
    let(:user)   { 'c66ec890601f16fdb53ae29525c9eb12fdc04746' }
    let(:key)    { 'a0887eca1aa61334449974fe6474671d3f2965c6' }

    let(:instance) { described_class.new(app, user, key) }
    subject { instance }

    describe '#call' do
      describe 'the url parameter' do
        let(:env)        { {url: url} }
        let(:signature)  { 'signature!' }
        let(:url_params) { { :host => HOST , :path => PATH } }
        subject         { url }

        context 'after being processed by the middleware' do
          before do
            BlueKaiMiddleware::Authenticate::SigningContext.should_receive(:new).with(env, key).and_return(signer)
            signer.should_receive(:signature).and_return(signature)

            app.should_receive(:call).with(env)

            instance.call(env)
          end

          its(:host)  { should eq(HOST) }
          its(:path)  { should eq(PATH) }
          its(:query) { should eq(Faraday::Utils.build_query({ 'bksig' => signature, 'bkuid' => user })) }
        end
      end
    end
  end

  describe BlueKaiMiddleware::Authenticate::SigningContext do
    let(:url_params) { { :host => HOST, :path => PATH, :query => 'secret=secret&name=BlueKai%20Test' } }
    let(:env) { {method: 'post', body: '{count: 4, data: [1, 2, 3, 4]}', url: url} }
    let(:key) { 'a0887eca1aa61334449974fe6474671d3f2965c6' }

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
    end
  end
end

describe 'BK middlware with Faraday 8.0 support' do
  it_behaves_like "Faraday version agnostic BK middleware" do
    let(:url)    { URI::HTTPS.build(url_params) }
  end
end
