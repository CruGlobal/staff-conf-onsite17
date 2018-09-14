ActiveAdmin.register Seminary do
  partial_view :index, :show, :form
  permit_params :name, :code, :course_price

  filter :name
  filter :code
end
