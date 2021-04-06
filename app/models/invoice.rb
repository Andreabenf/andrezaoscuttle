class Invoice < ApplicationRecord
  belongs_to :payment, optional: true
  belongs_to :client_sale
  belongs_to :invoice_data

  validates :pis_tax, :issqn_tax, :cofins_tax, :status, presence: true

  enum status: {
    pending: 'pending',
    emitted: 'emitted',
    error: 'error',
    in_process: 'in_process',
    paused: 'paused',
    canceled: 'canceled'
  }

  scope :sale, -> { joins(client_sale: :sale) }
  scope :client_sale, -> { joins(:client_sale) }

  scope :status, -> (status) { where(status: status) }
  scope :sale_id, -> (id) { sale.where('sales.id' => id) }

  scope :initial_sale_date, -> (date) { client_sale.where('client_sales.created_at > ?', date) }
  scope :final_sale_date, -> (date) do
    client_sale.where('client_sales.created_at < ?', final_date_filter(date))
  end

  scope :initial_emission_date, -> (date) { where('invoices.invoice_date > ?', date) }
  scope :final_emission_date, -> (date) do
    where('invoices.invoice_date < ?', final_date_filter(date))
  end

  def is_from_test?
    payment&.is_test || client_sale.is_test?
  end
end
