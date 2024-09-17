# frozen_string_literal: true
require 'rack'
require 'securerandom'

class RackRequestObjectLogger
  def initialize(app, request_model)
    @app = app
    @model = request_model
  end

  def call(env)
    start_time = Time.now.utc

    app_result = @app.call(env)

    end_time = Time.now.utc
    logger_object = @model.new
    logger_object.application_server_request_start = start_time
    logger_object.application_server_request_end = end_time
    logger_object.data = env.select do |header, value|
      # don't bother with values other than a string
      next if !value.is_a?(String)
      # https://tools.ietf.org/html/rfc3875 CGI 1.1 spec
      # reject cookies
      next if ['HTTP_COOKIE'].include?(header)

      # 1. predefined
      # 2. $scheme - rack is for HTTP, won't handle other protocols here
      # 3. http headers
      # 4. REQUEST_URI seems to be defined like everywhere (PHP, Python, Rack), but is not a part of CGI spec
      #    ORIGINAL_FULLPATH and ORIGINAL_SCRIPT_NAME is Rack specific
      [
          'AUTH_TYPE', 'CONTENT_LENGTH', 'CONTENT_TYPE', 'GATEWAY_INTERFACE', 'PATH_INFO',
          'PATH_TRANSLATED', 'QUERY_STRING', 'REMOTE_ADDR', 'REMOTE_HOST', 'REMOTE_IDENT',
          'REMOTE_USER', 'REQUEST_METHOD', 'SCRIPT_NAME', 'SERVER_NAME', 'SERVER_PORT',
          'SERVER_PROTOCOL', 'SERVER_SOFTWARE'
      ].include?(header) || ['HTTP', 'HTTPS'].include?(header) || header =~ /\AHTTP_\w+\z/ ||
      ['REQUEST_URI', 'ORIGINAL_FULLPATH', 'ORIGINAL_SCRIPT_NAME'].include?(header)
    end
    logger_object.uid = env['action_dispatch.request_id'] || SecureRandom.uuid
    logger_object.status_code = app_result.first
    logger_object.save
    app_result
  end
end
