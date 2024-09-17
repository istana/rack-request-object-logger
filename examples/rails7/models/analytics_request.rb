class AnalyticsRequest < ::ApplicationRecord
  belongs_to :requestable, polymorphic: true, required: false
end
