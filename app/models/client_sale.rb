class ClientSale < ApplicationRecord
  belongs_to :client, optional: true
  belongs_to :email, optional: true
  belongs_to :sale
  belongs_to :client_buyer, optional: true, class_name: 'Client'

  has_many :payments
  has_many :invoices

  validates :client_id, uniqueness: { scope: :sale_id }, if: :client_id

  scope :sale, -> { joins(:sale) }
  scope :payments, -> { joins(:payments) }
  scope :sale_status, -> (status) { sale.where('sales.status' => status) unless status.empty? }
  scope :with_item_type, -> (item_type) { sale.merge(Sale.with_item_type(item_type)) }
  scope :by_client, -> (client_id) do
    where(client_id: client_id).or(
      where(client_buyer_id: client_id)
    )
  end
  scope :item_identifier, -> (identifiers) { sale.merge(Sale.with_items_list(identifiers)) }
  scope :payment_status, -> (status) { payments.where('payments.status = ?', status) }
  scope :paid_payments, -> { payments.where('payments.status = ?', Payment.statuses[:paid]) }

  scope :by_item_identifier_and_client, -> (ids) do
    joins(:sale).where(
      'client_sales.client_id' => ids[:client_id],
      'sales.item_identifier' => ids[:item_identifier],
      'sales.status' => :active
    )
  end

  scope :dependents_by_item_identifier, -> (item_identifier) do
    joins(:sale)
    .select('dependent')
    .where(
      "client_sales.dependent IS NOT NULL
       AND sales.item_identifier = ?
       AND sales.status = 'active'",
       item_identifier
    )
  end

  scope :upgrade_available_tickets, -> (params) do
    joins(:sale).where(
      "client_id IS DISTINCT FROM client_buyer_id
      AND sales.item_identifier = ?
      AND sales.status = 'active'
      AND client_sales.id NOT IN (?)",
      params[:dependency_item_identifier],
      dependents_by_item_identifier(params[:upgrade_item_identifier])
    )
  end

  scope :clients, -> (filters) do
    joins(:client).joins(:email).merge(Client.filter(filters))
  end

  scope :buyers, -> (document = '') do
    buyers = joins(
      'LEFT JOIN client_sales client_sale_buyers
       ON client_sale_buyers.client_id = client_sales.client_buyer_id
       AND client_sales.client_id IS DISTINCT FROM client_sales.client_buyer_id'
    )
    .joins('LEFT JOIN sales sale_buyer ON client_sale_buyers.sale_id = sale_buyer.id')
    .joins(
      'LEFT JOIN sales ON client_sales.sale_id = sales.id
       AND sale_buyer.item_identifier = sales.item_identifier'
    )
    .joins('LEFT JOIN clients buyers ON buyers.id = client_sale_buyers.client_id')
    .joins('LEFT JOIN emails buyer_emails ON buyer_emails.id = client_sale_buyers.email_id')

    return buyers unless document.present?

    buyers.where('buyers.document = ?', document)
  end

  def is_companion?
    client_buyer_id != client_id
  end

  def client_sale_buyer
    client_buyer.client_sales.with_item_type(sale.item_identifier).first
  end

  def is_test?
    payments.where(is_test: true).count === payments.count
  end
end
