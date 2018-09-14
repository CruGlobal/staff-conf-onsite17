ActiveAdmin.register UserVariable do
  partial_view :index, :form
  partial_view show: { title: ->(var) { format('Variable %p', var.code) } }

  permit_params :code, :short_name, :value_type, :value, :description

  filter :code
  filter :value_type
  filter :created_at
  filter :updated_at
end
