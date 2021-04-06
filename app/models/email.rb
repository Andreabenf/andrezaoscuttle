class Email < ApplicationRecord
  belongs_to :client
  has_many :client_sales

  validates :address,
    presence: true,
    uniqueness: { case_sensitive: false, message: :taken_email },
    format: { with: URI::MailTo::EMAIL_REGEXP, message: :invalid_email }
end
