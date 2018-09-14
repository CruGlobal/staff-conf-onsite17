ActiveAdmin.register Payment do
  partial_view :index, :show, :form

  belongs_to :family

  permit_params :family_id, :payment_type, :cost_type, :price, :business_unit,
                :operating_unit, :department_code, :project_code, :reference,
                :comment

  filter :payment_type, as: :select, collection: -> { payment_type_ord_select }
  filter :cost_type,    as: :select, collection: -> { cost_type_ord_select }
  filter :comment
  filter :business_unit
  filter :operating_unit
  filter :department_code
  filter :project_code
  filter :reference
  filter :created_at
  filter :updated_at
end
