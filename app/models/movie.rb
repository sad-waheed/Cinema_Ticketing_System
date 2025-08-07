# frozen_string_literal: true

class Movie < ApplicationRecord
  has_many :shows, dependent: :destroy

  validates :title, presence: true
  validates :duration, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :rating_test

  # Validate rating against allowed list
  def rating_test
    valid_rating = %w[PG-13 R G NC-17]
    unless valid_rating.include?(rating)
      errors.add(:rating, "must be one of: #{valid_rating.join(', ')}")
    end
  end

  # Assign image data from an uploaded file (like from form file_field)
  def image=(file)
    return unless file.respond_to?(:read)
    self.image_data = file.read
  end

  # Return base64 encoded image string for embedding in views
  def image_base64
    return nil unless image_data
    "data:image/jpeg;base64,#{Base64.strict_encode64(image_data)}"
  end
end
