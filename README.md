# rack-request-object-logger

**Human description:** I created this to log all HTTP requests from my Rails application into MySQL database automatically. Then process via ElasticSearch.

**General concept:** Log HTTP requests via Rack stack to an object. Can use any object, because logger uses dependency injection in setup. Be independent of Rails.

Don't be confused with no commits in months or years. Rack middlewares rarely change. They just work for years.

## Install gem

```
gem install rack-request-object-logger
```

## Gemfile

```ruby
gem 'rack-request-object-logger'
```

## Example - logging to SQL database in Rails

generate a model for storage

```
$ bin/rails g model Sql::HttpRequest uuid:string headers:text

```

add JSON serialization
```
# app/models/sql/http_request.rb
class Sql::HttpRequest < ApplicationRecord
  serialize :headers, JSON
end

```

add automatic logging via initializer
```
# config/initializers/rack_middlewares.rb

Rails.application.config.middleware.use(RackRequestObjectLogger, Sql::HttpRequest)
```

## Rails integration/awareness

The logger sets the UUID of request to match the request ID set by Rails.

## Security considerations

The middleware stores all HTTP headers, but strips all *active_dispatch*, *warden* and other stuff. That means HTTP basic auth credentials are stored and also data in query string.

I've seen applications sending sensitive data in GET and even POST requests in a query string. Don't do that. Use POST body. Or modify the middleware to filter out them.

## Author & License

Copyright 2016 Ivan Stana, licensed under Apache 2.0 license. Enjoy.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/istana/rack-request-object-logger. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Alternatives

There may be better alternatives for you:

- http://bogomips.org/clogger/
- http://www.rubydoc.info/github/rack/rack/Rack/CommonLogger
- https://github.com/mattt/rack-http-logger
