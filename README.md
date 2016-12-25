[![Build Status](http://img.shields.io/travis/starmammoth/rack-request-object-logger.svg?style=flat-square)](https://travis-ci.org/starmammoth/rack-request-object-logger)
[![Dependency Status](http://img.shields.io/gemnasium/starmammoth/rack-request-object-logger.svg?style=flat-square)](https://gemnasium.com/starmammoth/rack-request-object-logger)
[![Code Climate](http://img.shields.io/codeclimate/github/starmammoth/rack-request-object-logger.svg?style=flat-square)](https://codeclimate.com/github/starmammoth/rack-request-object-logger)
[![Gem Version](http://img.shields.io/gem/v/rack-request-object-logger.svg?style=flat-square)](https://rubygems.org/gems/rack-request-object-logger)
[![License](http://img.shields.io/:license-apache-blue.svg?style=flat-square)](http://www.apache.org/licenses/LICENSE-2.0.html)

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

## Author

Copyright 2016 Ivan Stana, licensed under Apache 2.0 license. Enjoy.

## License

Copyright 2016 Ivan Stana

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0 (or see the file `LICENSE`)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

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
