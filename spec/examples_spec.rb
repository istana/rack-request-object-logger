# frozen_string_literal: true
require 'spec_helper'
require 'active_record'
require_relative '../examples/rails5/db/migrate/20170211004327_create_http_requests.rb'

class AnalyticsHttpRequest < ActiveRecord::Base
  serialize :headers, JSON
end

RSpec.describe '20170211004327_create_http_requests.rb' do
  # Rails 5.0+ finally suports subsecond info for datetime, but the migration must be right
  # ensure that dates are stored with subsecond information - the behavior is inconsistent
  # among the database engines

  # works on Sqlite3 3.16 (cannot find on the internet since when)
  it 'stores request start and end in subsecond resolution with sqlite3 adapter' do
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
    CreateAnalyticsHttpRequests.migrate(:up)

    time_with_micro_seconds = Time.utc(2017,3,1,21,43,5,123456)
    log = AnalyticsHttpRequest.create(
      application_server_request_start: time_with_micro_seconds,
      application_server_request_end: time_with_micro_seconds
    )

    expect(log.application_server_request_start.usec).to eq(123456)
    expect(log.application_server_request_end.usec).to eq(123456)
  end

  # works on MySQL 5.6 and higher / MariaDB 10+
  it 'stores request start and end in subsecond resolution with mysql2 adapter' do
    ActiveRecord::Base.establish_connection(
      adapter: 'mysql2',
      encoding: 'utf8',
      # WTF? cannot specify database here, otherwise everything, create_database included
      # will fail with ActiveRecord::NoDatabaseError: Unknown database 'examples_test'
      #database: 'examples_test',
      username: 'root',
      password: '',
      host: '127.0.0.1',
      port: 3306
    )
    ActiveRecord::Base.connection.execute('CREATE DATABASE IF NOT EXISTS examples_test;')
    ActiveRecord::Base.connection.execute('USE examples_test;')
    CreateAnalyticsHttpRequests.migrate(:up)

    time_with_micro_seconds = Time.utc(2017,3,1,21,43,5,123456)
    log = AnalyticsHttpRequest.create(
      application_server_request_start: time_with_micro_seconds,
      application_server_request_end: time_with_micro_seconds
    )

    expect(log.application_server_request_start.usec).to eq(123456)
    expect(log.application_server_request_end.usec).to eq(123456)

    ActiveRecord::Base.connection.execute('DROP DATABASE examples_test;')
  end
end
