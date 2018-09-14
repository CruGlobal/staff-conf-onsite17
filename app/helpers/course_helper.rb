module CourseHelper
  I18N_PREFIX_COURSE = 'activerecord.attributes.course'.freeze

  # @return [Array<[label, id]>] the {Course} +<select>+ options acceptable
  #   for +options_for_select+
  def courses_select
    Course.all.order(:position).map { |c| [c.name, c.id] }
  end

  def seminary_code(attendance)
    if attendance.seminary_credit
      attendance&.seminary&.code
    else
      'IBS'
    end
  end

  def grading_option(attendance)
    attendance.grade == 'AU' ? 'A' : 'G'
  end
end
