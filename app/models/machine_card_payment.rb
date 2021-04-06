class MachineCardPayment < ApplicationRecord
  belongs_to :card_payment
  has_one :payment, as: :payment_method

  delegate :authorization_date,
    :parcels,
    :purchaser,
    :credit_card_type,
    :authorization_date=,
    :parcels=,
    :purchaser=,
    :credit_card_type=,
    to: :card_payment,
    allow_nil: true

  def machine_card_payment
    card_payment.as_json(only: :parcels)
  end

  def purchase_data
    machine_card_payment
  end
end
