# frozen_string_literal: true
require_relative 'performance_helper'
require_relative '../spec/spec_data'
require 'active_record'

RSpec.describe "Performance testing with an ActiveRecord class and SQLite3 database", performance: true do
  include RSpec::Benchmark::Matchers
  include_context 'spec_data'

  class RequestActiveRecordLog < ActiveRecord::Base
    serialize :headers, JSON
  end

  class CreateRequestActiveRecordLog < ActiveRecord::Migration[4.2]
    def change
      create_table :request_active_record_logs do |t|
        t.integer :uid
        t.text :data
        t.time :application_server_request_start
        t.time :application_server_request_end
      end
    end
  end

  let(:app) { proc{ [200, {}, ['Hello, world.']] } }
  let(:stack) { RackRequestObjectLogger.new(app, RequestActiveRecordLog) }
  let(:request) { Rack::MockRequest.new(stack) }

  after { File.unlink 'active_record_performance.sqlite3' }

  it 'much fast. wow' do
    set_headers(rails5_puma_headers)

    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: 'active_record_performance.sqlite3'
    )
    CreateRequestActiveRecordLog.migrate(:up)
    expect { request.get('http://localhost:4000/doge') }.to perform_at_least(500).ips
  end
end
