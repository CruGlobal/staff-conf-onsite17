module AccountingReport
  class Row
    include ActiveModel::Model
    include ActiveRecord::AttributeAssignment
    include ActiveModel::Serializers::Xml

    # ActiveAdmin strips blank columns, so using a unicode NBSP method here
    # tricks it into rendering a blank column
    NBSP_COL = "\u00a0".to_sym
    define_method(NBSP_COL) { NBSP_COL }

    ATTRIBUTES = %i[id bus_unit oper_unit dept_id project account product amount
                    description reference intentional_blank family_id last_name
                    first_name spouse_first_name].freeze

    ATTRIBUTES.each { |name| attr_accessor name }

    def attributes
      Hash[
        ATTRIBUTES.map { |name| [name, send(name)] }
      ]
    end
  end
end
