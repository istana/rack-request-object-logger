require Rails.root.join('app', 'models', 'application_record').to_s
require Rails.root.join('app', 'models', 'analytics_request').to_s

Rails.configuration.before_initialize do
  Rails.application.config.middleware.use(
    RackRequestObjectLogger,
    ::AnalyticsRequest
  )
end
