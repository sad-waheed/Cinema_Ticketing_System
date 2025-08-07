# frozen_string_literal: true

class Show < ApplicationRecord
  belongs_to :movie
  belongs_to :hall
  has_many :bookings, dependent: :destroy
  has_many :booking_seats, dependent: :destroy

  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time
  validate :no_time_conflicts
  validate :date_not_in_past

  def no_time_conflicts
    return if hall.blank? || start_time.blank? || end_time.blank?

    overlapping = Show.where(hall_id: hall_id).where.not(id: id).where("start_time < ? AND end_time > ?", end_time,start_time).exists?
    errors.add(:base, "Time slot overlaps with another show in this hall") if overlapping
  end

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?
    errors.add(:end_time, "must be after start time") if end_time <= start_time
  end
  def date_not_in_past
    if start_time < Time.zone.now
      errors.add(:start_time, "can't be in the past")
    end
    return
  end
end
