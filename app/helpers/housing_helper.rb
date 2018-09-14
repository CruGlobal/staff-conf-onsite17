module HousingHelper
  I18N_PREFIX_HOUSING = 'activerecord.attributes.housing_facility'.freeze

  # @param type [HousingFacility, #to_s] either a facility record or the value
  #   of its +housing_type+ fields
  # @return [String] a string describing the given type
  def housing_type_label(type)
    type = type.housing_type if type.is_a?(HousingFacility)
    I18n.t("activerecord.attributes.housing_facility.housing_types.#{type}")
  end

  # @return [Array<[label, id]>] the {HousingFacility housing types} +<select>+
  #   options acceptable for +options_for_select+
  def housing_type_select
    HousingFacility.housing_types.map do |type, value|
      [housing_type_name(value), type]
    end
  end

  # @param obj [ApplicationRecord, Fixnum] either a record with a
  #   +housing_type+ field, or the ordinal value of the +housing_type+ enum
  # @return [String] the translated name of that type
  def housing_type_name(obj)
    # typecast an integer into an enum string
    type =
      case obj
      when ApplicationRecord
        obj.housing_type
      when Integer
        HousingFacility.new(housing_type: obj).housing_type
      else
        raise "unexpected parameter, '#{obj.inspect}'"
      end

    I18n.t("#{I18N_PREFIX_HOUSING}.housing_types.#{type}")
  end

  # Creates an input element, used by the JavaScript code in
  # +app/assets/javascripts/family/edit.coffee+ to dynamically show/hide this
  # HTML element.
  #
  # @see .dynamic_attribute_input
  def dynamic_preference_input(form, attribute, opts = {})
    dynamic_attribute_input(
      HousingPreference::HOUSING_TYPE_FIELDS, form, attribute, opts
    )
  end

  # Creates an input element, used by the JavaScript code in
  # +app/assets/javascripts/stay/dynamic_fields.coffee+ to dynamically
  # show/hide this HTML element.
  #
  # @see .dynamic_attribute_input
  def dynamic_stay_input(form, attribute, opts = {})
    dynamic_attribute_input(Stay::HOUSING_TYPE_FIELDS, form, attribute, opts)
  end

  # Creates input fields that can by dynamically shown/hidden whenver the user
  # changes the value of particular select box, controlled by JavaScript.
  def dynamic_attribute_input(attributes_map, form, attribute, opts = {})
    classes = attributes_map[attribute].map { |t| "for-#{t}" }.join(' ')

    opts[:wrapper_html] ||= {}
    opts[:wrapper_html][:class] = "dynamic-field #{classes}"

    form.input(attribute, opts)
  end

  # A helper method that generates the Housing
  # Type-{HousingFacility}-{HousingUnit} hierarchy used by the JavaScript
  # select widget.
  # @see .select_housing_unit_widget
  def housing_unit_hierarchy
    @hierarchy ||= HousingUnit.hierarchy

    {}.tap do |h|
      h['self_provided'] ||= {}

      @hierarchy.each do |type, facilities|
        h[type] ||= {}
        facilities.each do |facility, units|
          next if units.empty?
          h[type][facility.id] = {
            name: facility.name,
            units: units.natural_order_asc.pluck(:name, :id)
          }
        end
      end
    end
  end

  # @return [Array] All the housing units sorted by natural_order
  def housing_units
    @housing_units ||= HousingUnit.all.natural_order_asc
  end

  # @return [String] a short phrase describing how long the Stay will last
  def join_stay_dates(stay)
    dates =
      %i[arrived_at departed_at].map do |attr|
        next unless stay.send(attr)
        stay.send(attr).to_s(:db)
      end
    dates.compact.present? ? dates.join(' to ') : ''
  end
end
