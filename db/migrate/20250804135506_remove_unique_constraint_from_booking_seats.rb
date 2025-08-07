class RemoveUniqueConstraintFromBookingSeats < ActiveRecord::Migration[7.0]
  def up
    # Remove the unique index on show_id and seat_id
    remove_index :booking_seats, column: [:show_id, :seat_id]
  end

  def down
    # Add the unique index back if we need to rollback
    add_index :booking_seats, [:show_id, :seat_id], unique: true
  end
end