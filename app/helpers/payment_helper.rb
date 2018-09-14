module PaymentHelper
  I18N_PREFIX_PAYMENT = 'activerecord.attributes.payment'.freeze

  # @return [Array<[label, id]>] a map of {Payment} types and their
  #   descriptions
  def payment_type_select
    Payment.payment_types.map { |type, value| [payment_type_name(value), type] }
  end

  # Like {#payment_type_select}, but the second value is the enum's ordinal
  # value, and not its symbol value. ie: +1+ instead of +:credit_card+
  def payment_type_ord_select
    Payment.payment_types.map { |_, value| [payment_type_name(value), value] }
  end

  # @param obj [ApplicationRecord, Fixnum, String] either a record with a
  #   +payment_type+ field, the ordinal value of the +Payment#payment_type+
  #   enum, or the categorical (String) value of the +#payment_type+ enum
  # @return [String] the translated name of that type
  def payment_type_name(obj)
    # typecast an integer into an enum string
    type =
      case obj
      when String
        obj
      when ApplicationRecord
        obj.payment_type
      when Integer
        Payment.new(payment_type: obj).payment_type
      when nil
        nil
      else
        raise "unexpected parameter, '#{obj.inspect}'"
      end

    I18n.t("#{I18N_PREFIX_PAYMENT}.payment_types.#{type}")
  end
end
