module Import
  module Attributes
    class UpdateAttendee < ApplicationService
      MinistryMissing = Class.new(StandardError)

      # +Person+
      attr_accessor :person

      # +Import::Person+
      attr_accessor :import

      # +Array<Ministry>+
      attr_accessor :ministries

      before_initialize :default_ministries

      def call
        set_attendee_attributes
      end

      private

      def default_ministries
        # We allow the caller to pass an optional collection of ministries, to
        # avoid a large number of unneccessary SELECTs on repeat calls
        self.ministries ||= Ministry.all
      end

      def set_attendee_attributes
        person.assign_attributes(
          student_number: @import.student_number,
          tshirt_size: @import.tshirt_size,
          mobility_comment: @import.mobility_comment,
          phone: @import.phone,
          email: @import.email,
          conference_comment: @import.conference_comment,
          ibs_comment: @import.ibs_comment,
          conference_status: @import.conference_status
        )

        set_human_resource_attributes
        set_attendee_associations
      end

      # TODO: We don't use these attributes in this application, we just hold on
      #       to them to include in future reports
      def set_human_resource_attributes
        person.assign_attributes(
          ethnicity: @import.ethnicity,
          hired_at: @import.hired_at,
          employee_status: @import.employee_status,
          caring_department: @import.caring_department,
          strategy: @import.strategy,
          assignment_length: @import.assignment_length,
          pay_chartfield: @import.pay_chartfield,
          conference_status: @import.conference_status
        )
      end

      def set_attendee_associations
        person.conferences = find_conferences(@import.conference_choices)
        person.courses = find_courses(@import.ibs_courses)

        assign_ministry if @import.ministry_code.present?
      end

      def find_conferences(choices)
        return [] if choices.blank?

        choices.split(/\s*,\s*/).map do |name|
          begin
            Conference.find_by!(name: name)
          rescue ActiveRecord::ActiveRecordError
            raise t('errors.no_conference', name: name.inspect)
          end
        end
      end

      def find_courses(courses)
        return [] if courses.blank?

        courses.split(/\s*,\s*/).map do |name|
          begin
            Course.find_by!(name: name)
          rescue ActiveRecord::ActiveRecordError
            raise t('errors.no_course', name: name.inspect)
          end
        end
      end

      def assign_ministry
        ministry = ministries.find { |m| m.code == @import.ministry_code }
        raise MinistryMissing if ministry.blank?

        person.ministry = ministry
      end
    end
  end
end
