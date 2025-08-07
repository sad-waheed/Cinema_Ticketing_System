# frozen_string_literal: true

class BookingSeat < ApplicationRecord
  belongs_to :booking
  belongs_to :seat
  belongs_to :show
end
