class CreditCard < ApplicationRecord
  acts_as_paranoid

  belongs_to :client
  belongs_to :credit_card_type
  belongs_to :address, optional: true

  has_many :online_card_payments

  validates :token,
            :card_number,
            :card_owner_name,
            :invoice_document,
            presence: true

  def encrypted_id
    Encryption.encrypt(id)
  end
end
