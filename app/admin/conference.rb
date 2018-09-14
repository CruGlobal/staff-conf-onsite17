ActiveAdmin.register Conference do
  acts_as_list

  partial_view :index, :show, :form
  permit_params :name, :description, :start_at, :end_at, :price,
                :waive_off_campus_facility_fee, :staff_conference

  filter :name
  filter :description
  filter :start_at
  filter :end_at
  filter :staff_conference
  filter :created_at
  filter :updated_at
end
