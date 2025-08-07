# frozen_string_literal: true

class Hall < ApplicationRecord
  has_many :shows, dependent: :destroy
  has_many :seats, dependent: :destroy
  validates :name, presence: true,length: {minimum: 2, maximum: 100}
  validates :seats_count, numericality: {only_integer: true ,greater_than_or_equal_to: 0}
end
