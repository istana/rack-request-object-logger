class CreateAnalyticsRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :analytics_requests, id: :uuid do |t|
      t.text :uid
      t.json :data
      t.integer :status_code
      t.datetime :application_server_request_start
      t.datetime :application_server_request_end
      t.references :requestable, polymorphic: true, null: true, type: :uuid, index: true

      t.timestamps
    end
  end
end
