class CreateAnalyticsHttpRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :analytics_http_requests do |t|
      t.string :uid
      t.text :data
      t.integer :status_code
      # with limit: 6 we will store nanosecond resolution
      # for statistics and performance monitoring sub-second resolution is a must
      t.datetime :application_server_request_start, limit: 6
      t.datetime :application_server_request_end, limit: 6

      t.timestamps
    end
  end
end
