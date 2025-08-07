class User < ApplicationRecord
  has_many :bookings, dependent: :destroy
  has_secure_password

  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true, uniqueness: true, length: { maximum: 255 }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, confirmation: true, length: { minimum: 4}
  enum :role, { user: 0, admin: 1 }

end
