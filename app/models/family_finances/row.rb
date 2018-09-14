module FamilyFinances
  class Row
    include ActiveModel::Model
    include ActiveRecord::AttributeAssignment
    include MoneyRails::ActiveRecord::Monetizable
    include Monetizable

    # To make Monetizable work with ActiveModel
    define_model_callbacks :save

    attr_accessor :description, :price_cents

    monetize_attr :price_cents, allow_nil: true, numericality: {
      greater_than_or_equal_to: -1_000_000,
      less_than_or_equal_to:     1_000_000
    }

    protected

    # To make Monetizable work with ActiveModel
    def write_attribute(name, value)
      instance_variable_set("@#{name}", value)
    end
  end
end
