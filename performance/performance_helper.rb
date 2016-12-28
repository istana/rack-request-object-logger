# frozen_string_literal: true
require 'bundler/setup'
require 'rspec-benchmark'
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "rack-request-object-logger"
