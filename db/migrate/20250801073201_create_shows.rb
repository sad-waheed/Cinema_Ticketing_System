class CreateShows < ActiveRecord::Migration[8.0]
  def change
    create_table :shows do |t|
      t.references :movie, null: false, foreign_key: true
      t.references :hall, null: false, foreign_key: true
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false


      t.timestamps
    end
    add_index :shows, :start_time
    add_index :shows, [ :hall_id, :start_time ]
  end
end
