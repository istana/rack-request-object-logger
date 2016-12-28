# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'RackRequestObjectLogger for Rails request' do
  # all header except the very long ones
  # request.headers.to_h.reject{|k,v| k.in?(["puma.config", "action_dispatch.routes", "action_dispatch.remote_ip", "rack.session.options", "action_controller.instance", "action_dispatch.cookies"])}
  let(:rails5_puma_headers) do
    {
      "rack.version" => [1, 3],
      "rack.errors" => StringIO.new('#<IO:<STDERR>>'),
      "rack.multithread" => true,
      "rack.multiprocess" => false,
      "rack.run_once" => false,
      "rack.hijack?" => true,
      "rack.hijack" => StringIO.new('#<Puma::Client:0x3fdb250638cc @ready=true>'),
      "rack.input" => StringIO.new('#<Puma::NullIO:0x007fb646f1db88>'),
      "rack.url_scheme" => "http",
      "rack.after_reply" => [],
      "rack.session" => StringIO.new('#<ActionDispatch::Request::Session:0x7fb64a073ae8 not yet loaded>'),
      "rack.request.query_string" => "",
      "rack.request.query_hash" => {},
      "rack.request.cookie_hash" => {},
      "SCRIPT_NAME" => "",
      "QUERY_STRING" => "",
      "SERVER_PROTOCOL" => "HTTP/1.1",
      "SERVER_SOFTWARE" => "puma 3.6.2 Sleepy Sunday Serenity",
      "GATEWAY_INTERFACE" => "CGI/1.2",
      "REQUEST_METHOD" => "GET",
      "REQUEST_PATH" => "/lol",
      "REQUEST_URI" => "/lol",
      "SERVER_NAME" => "localhost",
      "SERVER_PORT" => "4000",
      "PATH_INFO" => "/lol",
      "REMOTE_ADDR" => "::1",
      "ROUTES_70210414172620_SCRIPT_NAME" => "",
      "ORIGINAL_FULLPATH" => "/lol",
      "ORIGINAL_SCRIPT_NAME" => "",
      "HTTP_VERSION" => "HTTP/1.1",
      "HTTP_HOST" => "localhost:4000",
      "HTTP_UPGRADE_INSECURE_REQUESTS" => "1",
      "HTTP_ACCEPT" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      "HTTP_USER_AGENT" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/602.3.12 (KHTML, like Gecko) Version/10.0.2 Safari/602.3.12",
      "HTTP_ACCEPT_LANGUAGE" => "en-us",
      "HTTP_ACCEPT_ENCODING" => "gzip, deflate",
      "HTTP_CONNECTION" => "keep-alive",
      "puma.socket" => StringIO.new('#<TCPSocket:fd 36>'),
      "action_dispatch.parameter_filter" => [:password],
      "action_dispatch.redirect_filter" => [],
      "action_dispatch.secret_token" => nil,
      "action_dispatch.secret_key_base" => 
      "1f6009534595b3497d036d11adaea7f0597f26bc153216c8ac961c2831e9585a21982feb8ecd6dd1a25eabfc4850d5e516482107c3d4e0fd46bad26f31ec5055",
      "action_dispatch.show_exceptions" => true,
      "action_dispatch.show_detailed_exceptions" => true,
      "action_dispatch.logger" => StringIO.new('some logger'),
      "action_dispatch.backtrace_cleaner" => StringIO.new('some backtrace silencer'),
      "action_dispatch.key_generator" => StringIO.new('some key generator'),
      "action_dispatch.http_auth_salt" => "http authentication",
      "action_dispatch.signed_cookie_salt" => "signed cookie",
      "action_dispatch.encrypted_cookie_salt" => "encrypted cookie",
      "action_dispatch.encrypted_signed_cookie_salt" => "signed encrypted cookie",
      "action_dispatch.cookies_serializer" => :json,
      "action_dispatch.cookies_digest" => nil,
      "action_dispatch.request_id" => "18f28286-d4d1-4378-b959-189db4a22754",
      "action_dispatch.request.path_parameters" => {:controller=>"greetings", :action=>"index"},
      "action_dispatch.request.content_type" => nil,
      "action_dispatch.request.request_parameters" => {},
      "action_dispatch.request.query_parameters" => {},
      "action_dispatch.request.parameters" => {"controller"=>"greetings", "action"=>"index"},
      "action_dispatch.request.formats" => StringIO.new('some formats'),
      "action_dispatch.request.unsigned_session_cookie" => {}
    }
  end

  let(:app) { proc{ [200, {}, ['Hello, world.']] } }
  let(:stack) { RackRequestObjectLogger.new(app, RequestDummyLog) }
  let(:request) { Rack::MockRequest.new(stack) }

  let(:logger_object) { RequestDummyLog.new }
  before { allow(RequestDummyLog).to receive(:new).and_return(logger_object) }

  it 'logs HTTP headers and CGI headers' do
    stub_const("Rack::MockRequest::DEFAULT_ENV", rails5_puma_headers)
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
    stub_const("Rack::MockRequest::DEFAULT_ENV", rails5_puma_headers)
    response = request.get('/')
    expect(logger_object.data['puma.socket']).to eq(nil)
  end

  it 'does not log action_dispatch.*' do
    stub_const("Rack::MockRequest::DEFAULT_ENV", rails5_puma_headers)
    response = request.get('/')
    expect(logger_object.data['action_dispatch.parameter_filter']).to eq(nil)
  end

  it 'sets uid of log to request ID from Rails' do
    stub_const("Rack::MockRequest::DEFAULT_ENV", rails5_puma_headers)
    response = request.get('/')
    expect(logger_object.uid).to eq('18f28286-d4d1-4378-b959-189db4a22754')
  end
end
