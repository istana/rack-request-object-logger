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
    set_headers(rails5_puma_headers)
  end

  it 'logs HTTP headers and CGI headers' do
    # needs absolute path, so SERVER_NAME is set correctly
    response = request.get('http://localhost:4000/lol')
    expect(logger_object.data['SCRIPT_NAME']).to eq('')
    expect(logger_object.data['QUERY_STRING']).to eq('')
    expect(logger_object.data['SERVER_PROTOCOL']).to eq('HTTP/1.1')
    expect(logger_object.data['SERVER_SOFTWARE']).to eq('puma 3.6.2 Sleepy Sunday Serenity')
    expect(logger_object.data['GATEWAY_INTERFACE']).to eq('CGI/1.2')
    expect(logger_object.data['REQUEST_METHOD']).to eq('GET')
    # https://groups.google.com/forum/#!topic/rack-devel/CkHsw84ttQ0
    # REQUEST_PATH is a legacy variable that is completely undefined in Rack.
    # Applications should use the Rack information, which should always be enough for any required purposes.
    # Yehuda Katz
    expect(logger_object.data['REQUEST_PATH']).to eq(nil)
    expect(logger_object.data['REQUEST_URI']).to eq('/lol')
    expect(logger_object.data['SERVER_NAME']).to eq('localhost')
    expect(logger_object.data['SERVER_PORT']).to eq('4000')
    expect(logger_object.data['PATH_INFO']).to eq('/lol')
    expect(logger_object.data['REMOTE_ADDR']).to eq('::1')
    expect(logger_object.data['ORIGINAL_FULLPATH']).to eq('/lol')
    expect(logger_object.data['ORIGINAL_SCRIPT_NAME']).to eq('')
    expect(logger_object.data['HTTP_VERSION']).to eq('HTTP/1.1')
    expect(logger_object.data['HTTP_HOST']).to eq('localhost:4000')
    expect(logger_object.data['HTTP_UPGRADE_INSECURE_REQUESTS']).to eq('1')
    expect(logger_object.data['HTTP_ACCEPT']).to eq('text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8')
    expect(logger_object.data['HTTP_USER_AGENT']).to eq('Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/602.3.12 (KHTML, like Gecko) Version/10.0.2 Safari/602.3.12')
    expect(logger_object.data['HTTP_ACCEPT_LANGUAGE']).to eq('en-us')
    expect(logger_object.data['HTTP_ACCEPT_ENCODING']).to eq('gzip, deflate')
    expect(logger_object.data['HTTP_CONNECTION']).to eq('keep-alive')
  end

  it 'does not log puma.* variables' do
    response = request.get('/')
    expect(logger_object.data['puma.socket']).to eq(nil)
  end

  it 'does not log action_dispatch.*' do
    response = request.get('/')
    expect(logger_object.data['action_dispatch.parameter_filter']).to eq(nil)
  end

  it 'sets uid of log to request ID from Rails' do
    response = request.get('/')
    expect(logger_object.uid).to eq('18f28286-d4d1-4378-b959-189db4a22754')
  end
end
