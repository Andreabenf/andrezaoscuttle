class CreditCardType < ApplicationRecord
  has_many :payments
  has_many :credit_cards

  validates :name, :slug, presence: true
end
