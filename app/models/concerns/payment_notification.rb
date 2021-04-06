module PaymentNotification
  extend ActiveSupport::Concern

  def notify_slack_opened_payment
    return unless should_notify?

    Notifier.notify(
      channel: notification_channel,
      text: text_notification
    )
  end

  private

    def should_notify?
      saved_change_to_status? && opened?
    end

    def text_notification
      payment_url = "Link: #{central_sales_client_base_uri}/formula/payments/#{id}?tab=payment"

      "#{notification_opened_payment_message}\n#{payment_url}"
    end

    def notification_opened_payment_message
      ENV['NOTIFY_OPENED_PAYMENT_MESSAGE']
    end

    def notification_channel
      "##{ENV['NOTIFY_OPENED_PAYMENT_CHANNEL']}"
    end

    def central_sales_client_base_uri
      ENV['CENTRAL_VENDAS_CLIENT']
    end
end