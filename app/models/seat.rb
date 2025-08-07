# frozen_string_literal: true

class Seat < ApplicationRecord
  belongs_to :hall, counter_cache: true
  has_many :booking_seats, dependent: :destroy
  has_many :bookings, through: :booking_seats

  validates :row, presence: true, length: { maximum: 5 }
  validates :seat_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :seat_number, uniqueness: { scope: [:hall_id, :row] }
end
