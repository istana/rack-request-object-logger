require 'spec_helper'

RSpec.describe 'RackRequestObjectLogger for rack-test request' do
  let(:rack_test_headers) do
    {
      "rack.version" => [1, 3],
      "rack.input" => StringIO.new('foo'),
      "rack.errors" => StringIO.new('bar'),
      "rack.multithread" => true,
      "rack.multiprocess" => true,
      "rack.run_once" => false,
      "rack.test" => true,
      "rack.url_scheme" => "http",
      "REQUEST_METHOD" => "GET",
      "SERVER_NAME" => "example.org",
      "SERVER_PORT" => "80",
      "QUERY_STRING" => "",
      "PATH_INFO" => "/",
      "HTTPS" => "off",
      "SCRIPT_NAME" => "",
      "CONTENT_LENGTH" => "0",
      "REMOTE_ADDR" => "127.0.0.1",
      "HTTP_HOST" => "example.org",
      "HTTP_COOKIE" => ""
    }
  end

  let(:app) { proc{ [200,{}, ['Hello, world.']] } }
  let(:stack) { RackRequestObjectLogger.new(app, RequestSql) }
  let(:request) { Rack::MockRequest.new(stack) }

  let(:logger_object) { RequestSql.new }
  before { allow(RequestSql).to receive(:new).and_return(logger_object) }

  it 'logs HTTP headers and CGI headers' do
    stub_const("Rack::MockRequest::DEFAULT_ENV", rack_test_headers)
    response = request.get('/')
    expect(logger_object.data['REQUEST_METHOD']).to eq('GET')
    expect(logger_object.data['SERVER_NAME']).to eq('example.org')
    expect(logger_object.data['SERVER_PORT']).to eq('80')
    expect(logger_object.data['QUERY_STRING']).to eq('')
    expect(logger_object.data['PATH_INFO']).to eq('/')
    expect(logger_object.data['HTTPS']).to eq('off')
    expect(logger_object.data['SCRIPT_NAME']).to eq('')
    expect(logger_object.data['CONTENT_LENGTH']).to eq('0')
    expect(logger_object.data['REMOTE_ADDR']).to eq('127.0.0.1')
    expect(logger_object.data['HTTP_HOST']).to eq('example.org')
  end

  it 'does not log cookies' do
    stub_const("Rack::MockRequest::DEFAULT_ENV", rack_test_headers)
    response = request.get('/')
    expect(logger_object.data['HTTP_COOKIE']).to eq(nil)
  end

  it 'does not log rack.* values' do
    stub_const("Rack::MockRequest::DEFAULT_ENV", rack_test_headers)
    response = request.get('/')
    expect(logger_object.data['rack.version']).to eq(nil)
    expect(logger_object.data['rack.input']).to eq(nil)
    expect(logger_object.data['rack.errors']).to eq(nil)
    expect(logger_object.data['rack.multithread']).to eq(nil)
    expect(logger_object.data['rack.multiprocess']).to eq(nil)
    expect(logger_object.data['rack.run_once']).to eq(nil)
    expect(logger_object.data['rack.test']).to eq(nil)
    expect(logger_object.data['rack.url_scheme']).to eq(nil)
  end

  it 'generates random uid when request ID is not present' do
    allow(SecureRandom).to receive(:uuid).and_return('6cd406c9-2d24-4117-b8bc-924950243979')
    stub_const("Rack::MockRequest::DEFAULT_ENV", rack_test_headers)
    response = request.get('/')
    expect(logger_object.uid).to eq('6cd406c9-2d24-4117-b8bc-924950243979')
  end
end
