module FamilyFinances
  class AttendeeReport < BaseReport
    attr_accessor :attendee

    def_delegator :stays_cost, :total_adjustments, :stay_adjustments
    def_delegator :facility_use_cost, :total_adjustments,
                  :facility_use_adjustments
    def_delegator :courses_cost, :total_adjustments, :course_adjustments
    def_delegator :rec_center_cost, :total_adjustments, :rec_center_adjustments
    def_delegator :conferences_cost, :total_adjustments, :conference_adjustments
    def_delegator :staff_conference_cost, :total_adjustments,
                  :staff_conference_adjustments

    i18n_scope 'family_finances'

    def cost_reports
      [stays_cost, facility_use_cost, courses_cost, staff_conference_cost,
       conferences_cost, rec_center_cost]
    end

    def on_campus_stays
      stay_scope.select(&:dormitory?).map(&method(:stay_row))
    end

    def off_campus_stays
      stay_scope.reject(&:dormitory?).map(&method(:stay_row))
    end

    def courses
      course_scope.flat_map(&method(:course_row))
    end

    def staff_conference
      staff_conference_scope.flat_map(&method(:conference_row))
    end

    def conferences
      conference_scope.flat_map(&method(:conference_row))
    end

    def rec_center
      return [] unless attendee.rec_pass?

      label = t('rec_pass',
                start: l(attendee.rec_pass_start_at, format: :month),
                finish: l(attendee.rec_pass_end_at, format: :month))
      Array(row(label, rec_center_cost.total))
    end

    def campus_facility_use
      # If their fee is $0, we want the label to be 'No Fee'
      label =
        if facility_use_cost.subtotal.positive?
          t('facility_use')
        else
          t('no_fee')
        end

      # If they don't have arrival/departure dates or housing, we want to
      # surface that.
      label = t('unknown_housing') if attendee.no_dates?

      Array(row(label, facility_use_cost.subtotal))
    end

    private

    def stay_row(stay)
      row(stay.to_s, Stay::SingleAttendeeCost.call(stay: stay).total)
    end

    def course_row(attendance)
      seminary =
        if attendance.seminary_credit?
          row(t('seminary.credit'), attendee.seminary.course_price)
        else
          row(t('seminary.no_credit'), 0)
        end

      [row(attendance.course.to_s, attendance.course.try(:price)), seminary]
    end

    def conference_row(conf)
      row(conf.to_s, conf.price)
    end

    def stay_scope
      attendee.stays.not_in_self_provided
    end

    def course_scope
      attendee.course_attendances
    end

    def staff_conference_scope
      attendee.conferences.where(staff_conference: true)
    end

    def conference_scope
      attendee.conferences.where(staff_conference: false)
    end

    def stays_cost
      @stays_cost ||= Stay::ChargeAttendeeCost.call(attendee: attendee)
    end

    def courses_cost
      @courses_cost ||= Course::ChargeAttendeeCost.call(attendee: attendee)
    end

    def staff_conference_cost
      @staff_conference_cost ||=
        StaffConference::ChargeAttendeeCost.call(attendee: attendee)
    end

    def conferences_cost
      @conferences_cost ||=
        Conference::ChargeAttendeeCost.call(attendee: attendee)
    end

    def rec_center_cost
      @rec_center_cost ||= RecPass::ChargePersonCost.call(person: attendee)
    end

    def facility_use_cost
      @facility_use_cost ||=
        FacilityUseFee::ChargeAttendeeCost.call(attendee: attendee)
    end
  end
end
