ActiveAdmin.register FoodHeadCount::Table, as: 'Food Head Count' do
  config.paginate = false
  actions :index

  # The default filters raise an error when using ActiveModel instead of
  # ActiveRecord
  config.filters = false
  sidebar('Filters') { render 'filter_form' }

  index do
    column(:date) { |food| I18n.l(food.date, format: :month) }

    column :cafeteria
    column :adult_breakfast
    column :adult_lunch
    column :adult_dinner

    column :child_breakfast
    column :child_lunch
    column :child_dinner
  end

  controller do
    def scoped_collection
      FoodHeadCount::Report.call(
        params.permit(:cafeteria, :start_at, :end_at)
      ).head_counts
    end

    # @see ActiveAdmin::ResourceController::DataAccess#collection_applies
    def collection_applies(*_args)
      [:pagination]
    end
  end
end
