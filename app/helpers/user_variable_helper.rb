module UserVariableHelper
  I18N_VARIABLE_PREFIX = 'activerecord.attributes.user_variable'.freeze

  # @return [String] a short description of the given {UserVariable}
  def user_variable_label(var)
    case var.value_type
    when 'money'
      humanized_money_with_symbol(var.value)
    when 'date'
      I18n.l(var.value, format: :long)
    when 'html'
      html_summary(var.value)
    else
      var.value.to_s
    end
  end

  # @return [String] a formatted version of the given {UserVariable}
  def user_variable_format(var)
    if var.value_type == 'html'
      html_full(var.value)
    else
      user_variable_label(var)
    end
  end

  def user_variable_type(var)
    I18n.t("#{I18N_VARIABLE_PREFIX}.value_types.#{var.value_type}")
  end
end
