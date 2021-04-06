require 'cpf_cnpj'

class Client < ApplicationRecord
  include DocumentHelper

  has_many :emails
  has_many :client_sales
  has_many :invoice_datas
  has_many :addresses
  has_many :credit_cards
  has_many :purchased_client_sales, class_name: 'ClientSale', foreign_key: :client_buyer_id
  has_many :sales, through: :purchased_client_sales

  validates :document, document: true, uniqueness: { case_sensitive: false, message: :taken_document }

  validates :name, :phone, :document, presence: true

  enum gender: { male: 'male', female: 'female' }

  scope :emails, -> { joins(:emails) }
  scope :sales, -> { joins(:sales) }

  scope :client_name, -> (name) { where('clients.name ilike ?', "%#{name}%") }
  scope :document, -> (document) { where(document: document) }
  scope :email, -> (email) { emails.where('emails.address ilike ?', "%#{email}%") }
  scope :item_identifier, -> (identifiers) do
    sales.merge(Sale.with_items_list(identifiers)).union(without_sale)
  end
  scope :company, -> (company) do
    sales.merge(Sale.with_item_type(company))
      .union(without_sale)
      .order('clients.name asc')
  end
  scope :without_sale, -> { where.not('clients.id': joins(:client_sales)) }
  scope :name_or_document, -> (query) do
    client_name(query).or(where('clients.document ilike ?', "%#{query}%"))
  end

  def serialize_to_invoice(email, invoice_data)
    as_json(only: %i[id phone])
      .merge!(email: email.as_json(only: :address), invoice_data: invoice_data.serialize_to_invoice)
  end
end
