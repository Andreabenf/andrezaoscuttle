class Sale < ApplicationRecord
  has_many :client_sales
  has_many :clients, through: :client_sales
  has_many :invoices, through: :client_sales
  has_many :payments, through: :client_sales
  has_many :emails, through: :client_sales

  belongs_to :address
  belongs_to :invoice_data

  after_update :update_cancellation_date

  validates :price, :status, :item_identifier, presence: true

  scope :with_items_list, -> (item_list) { where('item_identifier IN (?)', item_list) }
  scope :with_item_type, -> (item_type) { where('sales.item_identifier ilike ?', "%#{item_type}%") }
  scope :status, -> (status) { where(status: status) }
  scope :initial_create_date, -> (date) { where('sales.created_at >= ?', date) }
  scope :final_create_date, -> (date) { where('sales.created_at <= ?', final_date_filter(date)) }
  scope :active_but_expired, -> (limit) do
    where('status = ? and expiration_date < ?',
          'active', Time.now
    ).limit(limit)
  end

  scope :without_test, -> do
    joins(:payments)
      .group('sales.id')
      .having('COUNT(payments.id) filter (where payments.is_test = true) != COUNT(payments.id)')
  end

  enum status: {
    active: 'active',
    inactive: 'inactive',
    pending: 'pending',
    canceled: 'canceled',
    in_debit: 'in_debit',
    incomplete: 'incomplete',
    processing: 'processing',
    expired: 'expired'
  }

  def total_value_paid
    self.client_sales.paid_payments.sum(:value)
  end

  private

    def is_canceled?
      saved_change_to_status? && canceled?
    end

    def update_cancellation_date
      return unless is_canceled?

      update(cancellation_date: DateTime.now)
    end
end
