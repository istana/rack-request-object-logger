# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'RackRequestObjectLogger for Rails request' do
  include_context 'spec_data'

  let(:app) { proc{ [200, {}, ['Hello, world.']] } }
  let(:stack) { RackRequestObjectLogger.new(app, RequestDummyLog) }
  let(:request) { Rack::MockRequest.new(stack) }

  let(:logger_object) { RequestDummyLog.new }
  before do
    allow(RequestDummyLog).to receive(:new).and_return(logger_object)
  end

  it 'logs HTTP headers and CGI headers' do
    # needs absolute path, so SERVER_NAME is set correctly
    response = request.get('http://localhost:4000/foo', rails_headers)
    expect(logger_object.data['SCRIPT_NAME']).to eq('')
    expect(logger_object.data['QUERY_STRING']).to eq('')
    expect(logger_object.data['SERVER_PROTOCOL']).to eq('HTTP/1.1')
    expect(logger_object.data['SERVER_SOFTWARE']).to eq('puma 6.4.2 The Eagle of Durango')
    expect(logger_object.data['GATEWAY_INTERFACE']).to eq('CGI/1.2')
    expect(logger_object.data['REQUEST_METHOD']).to eq('GET')
    # https://groups.google.com/forum/#!topic/rack-devel/CkHsw84ttQ0
    # REQUEST_PATH is a legacy variable that is completely undefined in Rack.
    # Applications should use the Rack information, which should always be enough for any required purposes.
    # Yehuda Katz
    expect(logger_object.data['REQUEST_PATH']).to eq(nil)
    expect(logger_object.data['REQUEST_URI']).to eq('/foo')
    expect(logger_object.data['SERVER_NAME']).to eq('localhost')
    expect(logger_object.data['SERVER_PORT']).to eq('4000')
    expect(logger_object.data['PATH_INFO']).to eq('/foo')
    expect(logger_object.data['REMOTE_ADDR']).to eq('::1')
    expect(logger_object.data['ORIGINAL_FULLPATH']).to eq('/foo')
    expect(logger_object.data['ORIGINAL_SCRIPT_NAME']).to eq('')
    expect(logger_object.data['HTTP_VERSION']).to eq('HTTP/1.1')
    expect(logger_object.data['HTTP_HOST']).to eq('localhost:4000')
    expect(logger_object.data['HTTP_UPGRADE_INSECURE_REQUESTS']).to eq('1')
    expect(logger_object.data['HTTP_ACCEPT']).to eq('text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8')
    expect(logger_object.data['HTTP_USER_AGENT']).to eq('Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0')
    expect(logger_object.data['HTTP_ACCEPT_LANGUAGE']).to eq('sk,cs;q=0.8,en-US;q=0.5,en;q=0.3')
    expect(logger_object.data['HTTP_ACCEPT_ENCODING']).to eq('gzip, deflate, br')
    expect(logger_object.data['HTTP_CONNECTION']).to eq('keep-alive')
  end

  it 'does not log action_dispatch.* values' do
    response = request.get('/', rails_headers)
    expect(logger_object.data.keys.select{|key| key.match?(/\Aaction_dispatch\./) }).to eq([])
  end

  it 'does not log puma.* values' do
    response = request.get('/', rails_headers)
    expect(logger_object.data.keys.select{|key| key.match?(/\Apuma\./) }).to eq([])
  end

  it 'does not log rack.* values' do
    response = request.get('/', rack_headers)
    expect(logger_object.data.keys.select{|key| key.match?(/\Arack\./) }).to eq([])
  end

  it 'sets uid of log to request ID from Rails' do
    response = request.get('/', rails_headers)
    expect(logger_object.uid).to eq('6e4ec1cd-7501-4a82-a429-bee89d75a437')
  end
end
