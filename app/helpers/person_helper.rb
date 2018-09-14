module PersonHelper
  I18N_CHILD_PREFIX = 'activerecord.attributes.child'.freeze

  # @return [Family,nil] the family specified by the +family_id+ query param
  def param_family
    @param_family ||=
      if (id = params[:family_id])
        Family.find(id)
      end
  end

  def gender_select
    Person::GENDERS.map { |k, v| [v, k] }
  end

  def gender_name(g)
    Person::GENDERS[g.to_sym]
  end

  # Creates an HTML element showing the given person's age, with a mouse-over
  # +title+, reminding them that the date was calculated as of
  # +UserVariable[:child_age_cutoff]+, and not the current date.
  #
  # @return [String] An HTML +<span>+ wrapping {#age}
  def age_label(dob)
    cutoff_date = UserVariable[:child_age_cutoff]
    cutoff_title = "As of #{I18n.l(cutoff_date, format: :month)}"
    dob_age = age(dob)

    Arbre::Context.new(title: cutoff_title, age: dob_age) do
      span(title: "As of #{cutoff_title}") { age }
    end
  end

  def birthdate_label(person)
    if person.birthdate.present?
      person.birthdate
    else
      Arbre::Context.new { span('Empty', class: 'empty danger') }
    end
  end

  # @param dob [Date]
  # @return [Fixnum, nil] the age, in years, of a person born on the given
  #   date, or +nil+ if the given date is +nil+
  # @see UserVariable[:child_age_cutoff]
  def age(dob)
    dob = dob.birthdate if dob.is_a?(Person)
    return nil if dob.nil?

    as_of = UserVariable[:child_age_cutoff]

    as_of.year - dob.year - (after_birthday?(dob, as_of) ? 0 : 1)
  end

  # @return [Boolean] +true+ if +now+ is temporalily "after" +dob+, ingoring
  #   the +year+ of each
  def after_birthday?(dob, now)
    now.month > dob.month || (now.month == dob.month && now.day >= dob.day)
  end

  # @return [String] a string which attempts to uniquely identify the given
  #  family, using its +last_name+ and the +first_name+ of each of its {Attendee
  #  attendees}
  def family_label(family)
    "#{family.last_name}: #{family_attendees_sentence(family)}"
  end

  # @return [String] a comma-separated sentence of the attendee's first names
  #   in the given family
  def family_attendees_sentence(family)
    if family.attendees.any?
      family.attendees.map(&:first_name).to_sentence
    else
      'no attendees'
    end
  end

  def family_select
    @family_select ||= Family.all.includes(:attendees).map { |f| [f, f.id] }
  end

  def last_name_label(person)
    # TODO: remove this first case when certain everyone has a Family
    if person.family.nil?
      person.last_name
    elsif person.last_name == person.family.last_name
      family_label(person.family)
    else
      "#{person.last_name} (#{family_label(person.family)})"
    end
  end

  # @return [Array<[label, key]>] a map of {Child::GRADE_LEVELS keys} and their
  #   descriptions
  def grade_level_select
    Child::GRADE_LEVELS.map do |key|
      [grade_level_label(key), key]
    end
  end

  # @param obj [Person, String] either a {Person} or the value of that person's
  #   +grade_level+ attribute
  # @return [String] a description of the person's grade level.
  def grade_level_label(obj)
    case obj
    when Person
      grade_level_label(obj.grade_level)
    when nil
      nil
    else
      I18n.t("#{I18N_CHILD_PREFIX}.grade_levels.#{obj}")
    end
  end

  # @param current [String, Person] the current value, or a {Person} to extract
  #   their current status from
  def conference_status_select(current = nil)
    status = current.is_a?(Person) ? current.conference_status : current
    status = nil if Attendee::CONFERENCE_STATUSES.include?(status)

    (Array(status) + Attendee::CONFERENCE_STATUSES).map { |s| [s, s] }
  end
end
