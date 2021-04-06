class OnlineCardPayment < ApplicationRecord
  belongs_to :card_payment
  belongs_to :credit_card, optional: true
  has_one :payment, as: :payment_method

  before_save :mask_card_number

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

  scope :nsu_number, -> (number) { where(nsu_number: number) }
  scope :tid, -> (tid) { where(tid: tid) }
  scope :id_gmx, -> (id) { where(id_gmx: id) }
  scope :lr_number, -> (number) { where(lr_number: number) }
  scope :card_number, -> (number) { where('card_number ilike ?', "%#{number}%") }

  def online_card_payment
    card_payment.as_json(only: :parcels)
      .merge(as_json(only: :id_gmx))
  end

  def purchase_data
    card_payment.as_json(only: %i[parcels authorization_date])
  end

  def mask_card_number
    return unless card_number_changed?

    card_number.gsub!(/(?<=.{4}).(?=.{4})/, '*')
  end
end
