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
    request = Rack::Request.new(env)
    logger_object.data = request.env.select do |header, value|
      [
        'REQUEST_METHOD', 'SERVER_NAME', 'SERVER_PORT', 'QUERY_STRING', 'PATH_INFO',
        'HTTPS', 'SCRIPT_NAME', 'CONTENT_LENGTH', 'REMOTE_ADDR', 'HTTP_HOST'
      ].include? header
    end
    logger_object.save
    app_result
=begin
    
    # this may not be sufficient with warden/devise/other gems which put stuff into env
    # also need to filter figaro stuff, stack settings from AWS
    # TODO: pick only HTTP_* and the fields with ip address and CGI
    # TODO: respect Rails request id
    # TODO: filter sensitive params
    # TODO: generally consider to whitelist fields instead of blacklist_
    data = request.env.reject{|header, value| !value.is_a?(String) || header =~ /\Aactive_dispatch/ }

    m = @model.new
    # Rails+Puma adds request.uuid, but cannot use here
    # https://github.com/anveo/rack-request-id
    m.uuid = SecureRandom.uuid
    m.headers = data
=end
  end
end
