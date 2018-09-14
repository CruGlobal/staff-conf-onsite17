module MoneyHelper
  # Wraps Formtastic's +form.input+ helper, so that +monitize+'d attributes
  # will be managed by the jQuery money widget.
  #
  # @param form [Formtastic Form] the form DSL object
  # @param attribute_name [Symbol] the name of the association attribute
  def money_input_widget(form, attribute_name)
    form.input(
      attribute_name,
      as: :string,
      input_html: {
        'data-money-input' => true
      }
    )
  end
end
