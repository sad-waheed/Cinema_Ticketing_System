class CreateSeats < ActiveRecord::Migration[8.0]
  def change
    create_table :seats do |t|
      t.references :hall, null: false, foreign_key: true
      t.string :row, null: false
      t.integer :seat_number, null: false

      t.timestamps
    end

    add_index :seats, [ :hall_id, :row, :seat_number ], unique: true
  end
end
