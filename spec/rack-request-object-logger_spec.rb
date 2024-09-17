# frozen_string_literal: true
require 'spec_helper'

RSpec.describe RackRequestObjectLogger do
  let(:app) { proc{ [418, {}, ['Hello, world.']] } }
  let(:stack) { RackRequestObjectLogger.new(app, RequestDummyLog) }
  let(:request) { Rack::MockRequest.new(stack) }

  let(:logger_object) { RequestDummyLog.new }
  before { allow(RequestDummyLog).to receive(:new).and_return(logger_object) }

  it "has a version number" do
    expect(RackRequestObjectLogger::VERSION).not_to be nil
  end

  it 'stores start and end times of the request in rack/rails stack' do
    response = request.get('/')
    expect(logger_object.application_server_request_start).to be <= logger_object.application_server_request_end
  end

  it 'stores headers to data attribute' do
    expect(logger_object).to receive(:data=)
    response = request.get('/')
  end

  it 'stores HTTP return code to data attribute' do
    response = request.get('/')
    expect(logger_object.status_code).to eq(418)
  end

  it 'saves a log object' do
    expect(logger_object).to receive(:save)
    response = request.get('/')
  end

  it 'stores string values' do
    response = request.get('/', { 'REMOTE_ADDR' => 'bar' })
    expect(logger_object.data['REMOTE_ADDR']).to eq('bar')
  end

  it 'does not store non-string values' do
    stub_const("Rack::MockRequest::DEFAULT_ENV", { 'REMOTE_ADDR' => StringIO.new('baz') })
    response = request.get('/')
    expect(logger_object.data['REMOTE_ADDR']).to eq(nil)
  end

  it 'saves uid of a request' do
    expect(logger_object).to receive(:uid=)
    response = request.get('/')
  end
end
