module ChildcareHelper
  I18N_PREFIX_CHILDCARE = 'activerecord.attributes.childcare'.freeze

  # @return [Array<[label, id]>] the {Childcare::CHILDCARE_WEEKS childcare
  #   weeks} +<select>+ options acceptable for +options_for_select+
  def childcare_weeks_select
    Childcare::CHILDCARE_WEEKS.each_with_index.map do |_, index|
      [childcare_weeks_label(index), index]
    end
  end

  # @return [Array<[label, id]>] the {Childcare} +<select>+ options acceptable
  #   for +options_for_select+
  def childcare_spaces_select
    Childcare.all.order(:position, :name).map do |c|
      [chilcare_spaces_label(c), c.id]
    end
  end

  def chilcare_spaces_label(childcare)
    [
      childcare.name,
      childcare.teachers,
      childcare.location,
      childcare.room,
      "size:#{childcare.children.size}"
    ].join(' | ')
  end

  # @param child [Child] Some kid.
  # @return [Arbre::Context] an HTML +<ul>+ list of the {Childcare} weeks been
  #   attended by the given +Child+, or a message if the child is not attending
  #   any +Childcare+
  def childcare_weeks_list(child)
    labels = child.childcare_weeks.map { |w| childcare_level(child, w) }

    Arbre::Context.new do
      if labels.any?
        ul do
          labels.each { |week_label| li { week_label } }
        end
      else
        span I18n.t('activerecord.attributes.child.childcare_week_numbers.none')
      end
    end
  end

  # @param child [Child] Some kid.
  # @return [Arbre::Context] an HTML +<ul>+ list of the {Childcare} weeks in
  #   which the given +Child+ is receiving a hot lunch
  def hot_lunch_weeks_list(child)
    labels =
      child.hot_lunch_weeks.map do |w|
        format('%s Hot Lunch', childcare_weeks_label(w))
      end

    Arbre::Context.new do
      if labels.any?
        ul do
          labels.each { |week_label| li { week_label } }
        end
      else
        span I18n.t('activerecord.attributes.child.hot_lunch_week_numbers.none')
      end
    end
  end

  # @return [String] a string describing the Childcare week represented by the
  #   given integer
  def childcare_weeks_label(index)
    I18n.t("#{I18N_PREFIX_CHILDCARE}.weeks.week#{index}")
  end

  # @return [String] a description of the given childcare level, based on the
  #   child's age group
  def childcare_level(child, index)
    I18n.t(
      "activerecord.attributes.child.childcare_suffixes.#{child.age_group}",
      label: childcare_weeks_label(index)
    )
  end
end
