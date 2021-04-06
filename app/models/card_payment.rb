class CardPayment < ApplicationRecord
  belongs_to :credit_card_type, optional: true
  belongs_to :purchaser, required: false

  has_one :online_card_payment
  has_one :machine_card_payment

  validates :parcels, presence: true
end
