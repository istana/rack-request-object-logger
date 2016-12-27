require 'bundler/setup'
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "rack-request-object-logger"
require 'pry'

class RequestSql
  attr_accessor :application_server_request_start, :application_server_request_end, :data, :uid

  def save
    true
  end
end
