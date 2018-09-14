module MinistryHelper
  # Wraps Formtastic's +form.input :ministry, as: :select+ helper, so that our
  # custom jQuery widget can replace the select with a nicer UI widget.
  #
  # @param form [Formtastic Form] the form DSL object
  # @param attribute_name [Symbol] the name of the association attribute
  # @see app/assets/javascripts/ministry/select.coffee
  def select_ministry_widget(form, attribute_name = :ministry)
    ministries = Ministry.all

    form.input(
      attribute_name,
      as: :select,
      collection: ministries.map { |m| [m.to_s, m.id] },
      input_html: {
        'data-ministry-code' => true,
        'data-labels' => Hash[ministries.map { |m| [m.id, m.to_s] }].to_json,
        'data-hierarchy' => ministry_hierarchy(ministries).to_json
      },
      include_blank: true
    )
  end

  # @param relation [ActiveRecord::Relation] the ministries to build the
  #   hieararchy from
  # @param hierarchy [Hash<Ministry, Hash>] the hierarchy to render. If +nil+,
  #   will default to {Ministry#hierarchy}
  # @return [Hash<Fixnum, Hash] a map of IDs to sub-trees. Each key is the DB
  #   ID of a ministry, and each value is a sub-tree, representing the hierarchy
  #   of ministries "beneath" this one in the organizational structure. That
  #   sub-tree may be empty
  def ministry_hierarchy(relation, hierarchy = nil)
    hierarchy ||= Ministry.hierarchy(relation)

    {}.tap do |h|
      hierarchy.each do |ministry, subtree|
        h[ministry.id] = ministry_hierarchy(relation, subtree)
      end
    end
  end

  def ministries_with_labels
    hierarchy = Ministry.hierarchy
    ministries = []
    add_ministries_for_level(nil, hierarchy, ministries)
    ministries
  end

  def add_ministries_for_level(ministry, children, ministries, label_prefix = nil)
    if ministry
      label = [label_prefix, ministry.to_s].compact.join(' -> ')
      ministries << { label: label, value: ministry.id }
    else
      label = nil
    end
    children.each do |min, ch|
      add_ministries_for_level(min, ch, ministries, label)
    end
  end
end
