class InvoiceData < ApplicationRecord
  include DocumentHelper

  has_many :invoices
  belongs_to :address
  belongs_to :client

  validates :document, document: true
  validates :name, :document, presence: true

  scope :name_or_document, -> (query) do
    where('invoice_data.name ilike ?', "%#{query}%").or(
      where('invoice_data.document ilike ?', "%#{query}%")
    )
  end

  scope :by_client, -> (id) { joins(:client).where('clients.id': id) }

  def serialize_to_invoice
    as_json(only: %i[name document phone]).merge!(address: address.serialize_to_invoice)
  end
end
