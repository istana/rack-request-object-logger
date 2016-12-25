require 'spec_helper'

class RequestSql
  attr_accessor :application_server_request_start, :application_server_request_end

  def save
    true
  end
end

RSpec.describe RackRequestObjectLogger do
  let(:app) { proc{ [200,{}, ['Hello, world.']] } }
  let(:stack) { RackRequestObjectLogger.new(app, RequestSql) }
  let(:request) { Rack::MockRequest.new(stack) }

  it "has a version number" do
    expect(RackRequestObjectLogger::VERSION).not_to be nil
  end

  it 'calculates how much it takes to do request in rack/rails stack' do
    logger_object = RequestSql.new
    allow(RequestSql).to receive(:new).and_return(logger_object)

    response = request.get('/')
    expect(logger_object.application_server_request_start).not_to eq(nil)
    expect(logger_object.application_server_request_end).not_to eq(nil)
  end

  it 'saves a log object' do
    logger_object = RequestSql.new
    allow(RequestSql).to receive(:new).and_return(logger_object)

    expect(logger_object).to receive(:save)
    response = request.get('/')
  end
end
