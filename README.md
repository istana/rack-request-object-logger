![example workflow](https://github.com/istana/rack-request-object-logger/actions/workflows/ruby.yml/badge.svg)
[![Gem Version](http://img.shields.io/gem/v/rack-request-object-logger.svg?style=flat-square)](https://rubygems.org/gems/rack-request-object-logger)
[![License](http://img.shields.io/:license-apache-blue.svg?style=flat-square)](http://www.apache.org/licenses/LICENSE-2.0.html)

# rack-request-object-logger

The project is a Rack middleware to automatically log a HTTP request to a custom object.

There might be no commits in months or years. Rack middlewares rarely change.

## Install gem

```bash
gem install rack-request-object-logger
```

## Gemfile

```ruby
gem 'rack-request-object-logger'
```

## Rubies Support

Tested with Matz Ruby 2.7, 3.0, 3.1, 3.2, 3.3, head, and ruffleruby, truffleruby-head.

Should work also with jRuby, just sqlite3 adapter supports only Rails 7 and tests require a more recent Rails.

## Roadmap

While the code works flawlessly

Bug: I learned at EuRuKo 2018 that my implementation of timings is wrong and not very accurate.

## Example - logging to SQL database in Rails

generate a model for storage

```bash
$ bin/rails g model AnalyticsRequest uid:string data:jsonb status_code:integer application_server_request_start:datetime application_server_request_end:datetime
```

add automatic logging via initializer

```ruby
# config/initializers/log_requests.rb

Rails.application.config.middleware.use(RackRequestObjectLogger, AnalyticsHttpRequest)
```

# Performance

To run performance tests on your computer run `rspec performance/`. On my i5 laptop with ActiveRecord it processes and stores 500 logs per second, with dummy class 5000.

## Rails Integration/Awareness

The logger sets the UUID of request to match the request ID set by Rails.

## Security considerations

The middleware stores all HTTP headers, but strips all *active_dispatch*, *warden* and other stuff. That means HTTP basic auth credentials are stored and also data in query string.

I've seen applications sending sensitive data in GET and even POST requests in a query string. Don't do that. Use POST body. Or modify the middleware to filter out them.

## License & Author

Copyright 2016-2024 Ivan Stana

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0 (or see the file `LICENSE`)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

...Enjoy

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
