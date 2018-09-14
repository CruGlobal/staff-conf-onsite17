ActiveAdmin.register CourseAttendance, as: 'IBS Course' do
  actions :index
  partial_view :index

  csv do
    column :id
    column('Student', sortable: 'people.last_name') { |ca| ca.attendee.full_name }
    column('Student Number', sortable: 'people.student_number') do |ca|
      ca.attendee.student_number
    end
    column('Class', sortable: 'course.name', &:course)
    column('IBS ID', sortable: 'course.ibs_code') { |ca| ca.course.try(:ibs_code) }
    column('Seminary Partner Code') { |ca| seminary_code(ca) }
    column('Course Grade', sortable: 'course.grade', &:grade)
    column('Grading Option') { |ca| grading_option(ca) }
  end

  controller do
    def scoped_collection
      end_of_association_chain.includes(:attendee, :course)
    end
  end

  filter :attendee_first_name_or_attendee_last_name_cont, label: 'Student'
  filter :attendee_student_number_cont, label: 'Student Number'
  filter :course_name_cont, label: 'Class'
  filter :grade, as: :select, collection: -> { CourseAttendance.grades }
end
