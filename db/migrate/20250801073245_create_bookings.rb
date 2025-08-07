class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :show, null: false, foreign_key: true
      t.integer :status, default: 0, null: false  # enum: e.g. pending, confirmed, cancelled

      t.timestamps  # includes created_at = booking_time
    end
    add_index :bookings, :status
    add_index :bookings, :created_at
  end
end
