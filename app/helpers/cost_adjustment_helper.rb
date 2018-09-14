module CostAdjustmentHelper
  I18N_PREFIX_COST_ADJUSTMENT = 'activerecord.attributes.cost_adjustment'.freeze

  # @return [Array<[label, id]>] a map of {CostAdjustment} IDs and their
  #   descriptions
  def cost_type_select
    CostAdjustment.cost_types.map do |type, value|
      [cost_type_name(value), type]
    end
  end

  # Like {#cost_type_select}, but the second value is the enum's ordinal value,
  # and not its symbol value. ie: +2+ instead of +:apartment_rent+
  def cost_type_ord_select
    CostAdjustment.cost_types.map { |_, value| [cost_type_name(value), value] }
  end

  # @param obj [ApplicationRecord, Fixnum, String] either a record with a +cost_type+
  #   field, the ordinal value of the +CostAdjustment#cost_type+ enum,
  #   or the categorical (String) value of the +CostAdjustment#cost_type+ enum
  # @return [String] the translated name of that type
  def cost_type_name(obj)
    # typecast an integer into an enum string
    type =
      case obj
      when String
        obj
      when ApplicationRecord
        obj.cost_type
      when Integer
        CostAdjustment.new(cost_type: obj).cost_type
      when nil
        nil
      else
        raise "unexpected parameter, '#{obj.inspect}'"
      end

    I18n.t("#{I18N_PREFIX_COST_ADJUSTMENT}.cost_types.#{type}")
  end

  def cost_adjustment_amount(cost_adjustment)
    if cost_adjustment.percent.present?
      "#{cost_adjustment.percent}%"
    else
      humanized_money_with_symbol(cost_adjustment.price)
    end
  end
end
