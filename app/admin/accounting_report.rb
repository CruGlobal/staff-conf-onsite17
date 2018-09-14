ActiveAdmin.register AccountingReport::Table, as: 'Accounting Report' do
  config.paginate = false
  actions :index
  belongs_to :family

  # The default filters raise an error when using ActiveModel instead of
  # ActiveRecord
  config.filters = false
  # TODO: sidebar('Filters') { render 'filter_form' }

  index do
    column :bus_unit
    column :oper_unit
    column :dept_id
    column :project
    column :account
    column :product
    column(:amount) { |row| humanized_money_with_symbol(row.amount) }
    column :description
    column :reference
    column :family_id
    column :last_name
    column :first_name
    column('Spouse') { |row| row.spouse_first_name }
  end

  controller do
    def scoped_collection
      AccountingReport::Report.call(
        params.permit(:family_id, :start_at, :end_at)
      ).table
    end

    # @see ActiveAdmin::ResourceController::DataAccess#collection_applies
    def collection_applies(*_args)
      [:pagination]
    end
  end
end
