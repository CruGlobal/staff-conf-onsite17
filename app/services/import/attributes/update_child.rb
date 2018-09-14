module Import
  module Attributes
    class UpdateChild < ApplicationService
      # +Person+
      attr_accessor :person

      # +Import::Person+
      attr_accessor :import

      def call
        set_child_attributes
      end

      private

      def set_child_attributes
        person.assign_attributes(
          needs_bed: @import.needs_bed,
          grade_level: @import.grade_level,
          childcare_deposit: @import.childcare_deposit,
          childcare_comment: @import.childcare_comment
        )

        person.childcare_weeks = childcare_weeks(@import.childcare_weeks)
        person.hot_lunch_weeks = childcare_weeks(@import.hot_lunch_weeks)
      end

      def childcare_weeks(weeks)
        # "SC" is short for "Staff Conference", the last week
        corrected_names =
          (weeks || '').split(/\s*,\s*/).map do |week|
            week == 'SC' ? Childcare::CHILDCARE_WEEKS.last : week
          end

        corrected_names.map { |name| Childcare::CHILDCARE_WEEKS.index(name) }
      end
    end
  end
end
