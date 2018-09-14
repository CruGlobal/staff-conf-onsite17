FactoryGirl.define do
  factory :course_attendance do
    course
    attendee
    grade { rand(100) }
  end
end
