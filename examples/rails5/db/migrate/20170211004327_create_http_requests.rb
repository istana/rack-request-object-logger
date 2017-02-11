class CreateHttpRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :http_requests do |t|
      t.string :uid
      t.text :data
      t.integer :status_code

      t.timestamps
    end
  end
end
