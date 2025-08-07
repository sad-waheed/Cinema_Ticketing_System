# frozen_string_literal: true

class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :show
  has_many :booking_seats, dependent: :destroy
  has_many :seats, through: :booking_seats
  enum :status, { pending: 0, confirmed: 1, cancelled: 2 }
  validates :status, presence: true
  validate :seats_do_not_exceed_capacity , unless: :cancelled?
  private
    def seats_do_not_exceed_capacity
      return if show.blank? || seats.blank?

      # Get all seat_ids for this show from bookings that are NOT cancelled
      booked_seat_ids = BookingSeat
                          .joins(:booking)
                          .where(show_id: show_id)
                          .where.not(bookings: { status: "cancelled" })
                          .pluck(:seat_id)

      new_seat_ids = seats.map(&:id)

      if (booked_seat_ids & new_seat_ids).any?
        errors.add(:seats, "include already booked seats for this show")
      end
    end


    def cancelling?
      status_changed? && status == "cancelled"
    end

end
