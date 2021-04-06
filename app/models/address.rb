class Address < ApplicationRecord
  belongs_to :city
  belongs_to :client
  has_many :invoice_datas

  validates :address, :district, presence: true

  delegate :state_initials, :country, to: :city
  delegate :state, to: :city

  def serialize_to_invoice
    as_json(except: %i[id city_id client_id]).merge!(
      city: city.as_json(only: %i[id name]),
      state: state.as_json(only: %i[id name initials]),
      country: state.country.as_json(only: %i[id name initials])
    )
  end
end
