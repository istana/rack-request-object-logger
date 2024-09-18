# frozen_string_literal: true
require_relative 'performance_helper'
require_relative '../spec/spec_data'
require 'active_record'

RSpec.describe "Performance testing with an ActiveRecord class and SQLite3 database", performance: true do
  include RSpec::Benchmark::Matchers
  include_context 'spec_data'

  class RequestActiveRecordLog < ActiveRecord::Base
  end

  class CreateRequestActiveRecordLog < ActiveRecord::Migration[7.0]
    def change
      create_table :request_active_record_logs do |t|
        t.text :uid
        t.integer :status_code
        t.json :data
        t.time :application_server_request_start
        t.time :application_server_request_end
      end
    end
  end

  let(:app) { proc{ [200, {}, ['Hello, world.']] } }
  let(:stack) { RackRequestObjectLogger.new(app, RequestActiveRecordLog) }
  let(:request) { Rack::MockRequest.new(stack) }

  after do
    File.unlink 'active_record_performance.sqlite3'
    File.unlink 'active_record_performance.sqlite3-shm'
    File.unlink 'active_record_performance.sqlite3-wal'
  end

  it 'much fast. wow' do
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: 'active_record_performance.sqlite3'
    )
    CreateRequestActiveRecordLog.migrate(:up)
    expect { request.get('http://localhost:4000/doge', rails_headers) }.to perform_at_least(200).ips.warmup(10)
  end
end
