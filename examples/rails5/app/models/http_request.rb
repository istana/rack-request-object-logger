class HttpRequest < ApplicationRecord
  serialize :data, JSON
end