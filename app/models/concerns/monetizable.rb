module Monetizable
  extend ActiveSupport::Concern

  included do
    # Wraps the +money-rails+ gem to work with input provided by the jQuery
    # format_price Javascript input. ex: +US$ 1,234.56+
    #
    # @see https://github.com/RubyMoney/money-rails
    # @see http://jquerypriceformat.com
    def self.monetize_attr(*fields)
      options = fields.extract_options!

      fields.each do |field|
        monetize(field, options)

        prefix = options[:as] || field.to_s.sub(/_cents$/, '')
        setter = "#{prefix}_without_strip="

        define_method "#{prefix}_with_strip=" do |value|
          value = value.gsub(/[^\d.]/, '').to_f if value.is_a?(String)
          send(setter, value)
        end

        alias_method_chain "#{prefix}=", :strip
      end
    end
  end
end
