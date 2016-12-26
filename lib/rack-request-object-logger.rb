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
      # https://tools.ietf.org/html/rfc3875 CGI 1.1 spec
      #static
      ([
        'AUTH_TYPE', 'CONTENT_LENGTH', 'CONTENT_TYPE', 'GATEWAY_INTERFACE', 'PATH_INFO',
        'PATH_TRANSLATED', 'QUERY_STRING', 'REMOTE_ADDR', 'REMOTE_HOST', 'REMOTE_IDENT',
        'REMOTE_USER', 'REQUEST_METHOD', 'SCRIPT_NAME', 'SERVER_NAME', 'SERVER_PORT',
        'SERVER_PROTOCOL', 'SERVER_SOFTWARE'
      ].concat(
        # $scheme - rack is for HTTP, won't handle other protocols here
        ['HTTP', 'HTTPS']
      ).include?(header) || header =~ /\AHTTP_\w+\z/) && value.is_a?(String)
      # and CGI also allows HTTP_ variables which are http headers from http request
    end
    logger_object.save
    app_result
=begin
    
    # TODO: respect Rails request id
    # TODO: filter sensitive params
    # Rails+Puma adds request.uuid, but cannot use here
    # https://github.com/anveo/rack-request-id
    m.uuid = SecureRandom.uuid
    m.headers = data
=end
  end
end
