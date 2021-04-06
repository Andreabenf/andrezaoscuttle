class Payment < ApplicationRecord
  include PaymentNotification

  belongs_to :client_sale
  belongs_to :payment_method, polymorphic: true
  has_one :invoice

  after_update :notify_slack_opened_payment

  validates :value, :payment_method_type, presence: true

  enum currencies: { real: 'real', dolar: 'dolar', euro: 'euro' }
  enum status: {
    opened: 'opened',
    paid: 'paid',
    canceled: 'canceled',
    fraud: 'fraud',
    charge_back: 'charge_back',
    approved: 'approved',
    repproved: 'repproved',
    communication_failure: 'communication_failure',
    to_pay: 'to_pay',
    cancelation_error: 'cancelation_error',
    pre_approved: 'pre_approved',
    incomplete: 'incomplete',
    overdue: 'overdue',
    disabled: 'disabled'
  }

  before_update :set_dates

  scope :sale, -> { joins(client_sale: :sale) }
  scope :client_sale_email, -> { joins(client_sale: :email) }
  scope :invoice, -> { joins(:invoice) }

  scope :status, -> (status) { where(status: status) }
  scope :payment_method, -> (payment) { where(payment_method_type: "#{payment.camelize}Payment") }

  scope :initial_create_date, -> (date) { where('payments.created_at >= ?', date) }
  scope :final_create_date, -> (date) { where('payments.created_at <= ?', final_date_filter(date)) }

  scope :initial_payment_date, -> (date) { where('payments.payment_date > ?', date) }
  scope :final_payment_date, -> (date) { where('payments.payment_date < ?', final_date_filter(date)) }

  scope :initial_cancel_date, -> (date) { where('payments.cancel_date > ?', date) }
  scope :final_cancel_date, -> (date) { where('payments.cancel_date < ?', final_date_filter(date)) }

  scope :initial_invoice_date, -> (date) { invoice.where('invoices.invoice_date > ?', date) }
  scope :final_invoice_date, -> (date) { invoice.where('invoices.invoice_date < ?', final_date_filter(date)) }

  scope :email, -> (address) { client_sale_email.where('emails.address ilike ?', "%#{address}%") }

  scope :item_identifier, -> (identifiers) { sale.merge(Sale.with_items_list(identifiers)) }

  scope :client, -> { joins(client_sale: :client) }

  scope :client_name, -> (name) { client.where('clients.name ilike ?', "%#{name}%") }
  scope :client_document, -> (document) { client.where('clients.document = ?', document) }

  scope :client_sale_id, -> (id) { where('payments.client_sale_id = ?', id) }
  scope :order_by_create_date, -> (order) { order('payments.created_at': order) }
  scope :order_by_payment_date, -> (order) { order('payments.payment_date': order) }
  scope :order_by_due_date, -> (order) { order('payments.due_date': order) }

  scope :online_card_method, -> do
    joins("LEFT JOIN online_card_payments
    ON payments.payment_method_type = 'OnlineCardPayment'
    AND payments.payment_method_id = online_card_payments.id")
  end

  scope :deposit_method, -> do
    joins("LEFT JOIN deposit_payments
    ON payments.payment_method_type = 'DepositPayment'
    AND payments.payment_method_id = deposit_payments.id")
  end

  scope :nsu_number, -> (number) do
    online_card_method.merge(OnlineCardPayment.nsu_number(number))
  end

  scope :tid, -> (tid) do
    online_card_method.merge(OnlineCardPayment.tid(tid))
  end

  scope :id_gmx, -> (id) do
    online_card_method.merge(OnlineCardPayment.id_gmx(id))
  end

  scope :lr_number, -> (number) do
    online_card_method.merge(OnlineCardPayment.lr_number(number))
  end

  scope :card_number, -> (number) do
    online_card_method.merge(OnlineCardPayment.card_number(number))
  end

  scope :deposit_number, -> (number) do
    deposit_method.merge(DepositPayment.document_number(number))
  end

  def set_dates
    date = DateTime.now

    return self.payment_date = date if paid? && self.payment_date == nil

    return self.cancel_date = date if canceled?
  end

  def invoice_data
    client_sale.sale.invoice_data
  end

  def is_deposit?
    self.payment_method_type == 'DepositPayment'
  end

  def client
    self.client_sale.client_buyer
  end
end
