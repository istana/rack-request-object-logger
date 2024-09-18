# frozen_string_literal: true
require_relative 'performance_helper'
require_relative '../spec/spec_data'

RSpec.describe "Performance testing with a dummy class", performance: true do
  include RSpec::Benchmark::Matchers
  include_context 'spec_data'

  let(:app) { proc{ [200, {}, ['Hello, world.']] } }
  let(:stack) { RackRequestObjectLogger.new(app, RequestDummyLog) }
  let(:request) { Rack::MockRequest.new(stack) }

  let(:logger_object) { RequestDummyLog.new }
  before { allow(RequestDummyLog).to receive(:new).and_return(logger_object) }

  it 'much fast. wow' do
    expect { request.get('http://localhost:4000/doge', rails_headers) }.to perform_at_least(5000).ips
  end
end
