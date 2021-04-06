class DepositPayment < ApplicationRecord
  PERMITED_FORMAT_TYPES = ['png', 'jpeg', 'pdf']

  has_one :payment, as: :payment_method

  scope :document_number, -> (number) { where('deposit_payments.document ilike ?', "%#{number}%") }

  def deposit_payment
    as_json(only: :deposit_receipt)
  end

  def purchase_data
    deposit_payment
  end
end
