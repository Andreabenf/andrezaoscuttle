class Purchaser < ApplicationRecord
  has_many :card_payments

  scope :purchaser_name, -> (name) { where('purchasers.name ilike ?', "%#{name}%") }
end
