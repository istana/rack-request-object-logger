require 'rack'
require 'securerandom'

class RackRequestObjectLogger
  def initialize(app, request_model)
    @app = app
    @model = request_model
  end

  def call(env)
    request = Rack::Request.new(env)
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

    if !m.save
      # TODO logger or something
      # I'm too lazy
    end

    @app.call(env)
  end
end
