module Import
  class UpdatePersonFromImport < ApplicationService
    MinistryMissing = Class.new(StandardError)

    # +Person+
    attr_accessor :person

    # +Import::Person+
    attr_accessor :import

    # +Array<Ministry>+
    attr_accessor :ministries

    def call
      set_common_attributes

      set_attendee_attributes if person.is_a?(Attendee)
      set_child_attributes if person.is_a?(Child)
    end

    private

    def set_common_attributes
      person.assign_attributes(
        first_name: @import.first_name,
        last_name: @import.last_name,
        name_tag_first_name: @import.name_tag_first_name,
        name_tag_last_name: @import.name_tag_last_name,
        gender: @import.gender,
        birthdate: @import.birthdate,
        personal_comment: @import.personal_comment,
        arrived_at: @import.arrived_at,
        departed_at: @import.departed_at,
        rec_pass_start_at: @import.rec_pass_start_at,
        rec_pass_end_at: @import.rec_pass_end_at
      )
    end

    def set_attendee_attributes
      Import::Attributes::UpdateAttendee.call(person: person, import: import,
                                              ministries: ministries)
    end

    def set_child_attributes
      Import::Attributes::UpdateChild.call(person: person, import: import)
    end
  end
end
