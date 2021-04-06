class BilletPayment < ApplicationRecord
  has_one :payment, as: :payment_method

  validates :external_billet_id, uniqueness: true, if: :external_billet_id

  def billet_payment
    as_json
  end

  def purchase_data
    as_json(only: %i[billet_number due_date])
  end
end
