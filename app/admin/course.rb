ActiveAdmin.register Course do
  acts_as_list

  partial_view :index, :show, :form
  permit_params :name, :instructor, :description, :week_descriptor, :ibs_code,
                :price, :location

  filter :name
  filter :instructor
  filter :description
  filter :week_descriptor
  filter :ibs_code
  filter :location
  filter :created_at
  filter :updated_at
end
