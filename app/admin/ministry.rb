ActiveAdmin.register Ministry do
  partial_view :index, :show, :form
  permit_params :name, :code, :name, :parent_id

  filter :code
  filter :name
  filter :created_at
  filter :updated_at

  collection_action :new_spreadsheet, title: 'Import Spreadsheet'
  action_item :import_spreadsheet, only: :index do
    if authorized?(:import, Ministry)
      link_to 'Import Spreadsheet', action: :new_spreadsheet
    end
  end

  collection_action :import_ministries, method: :post do
    return head :forbidden unless authorized?(:import, Ministry)

    import_params =
      ActionController::Parameters.new(params).
        require(:spreadsheet_import_ministries).permit(:file, :skip_first)

    job = UploadJob.create!(user_id: current_user.id,
                            filename: import_params[:file].path)
    ImportMinistriesSpreadsheetJob.perform_later(job.id,
                                                 import_params[:skip_first])

    redirect_to job
  end

  collection_action :import_hierarchy, method: :post do
    return head :forbidden unless authorized?(:import, Ministry)

    import_params =
      ActionController::Parameters.new(params).
        require(:spreadsheet_import_hierarchy).permit(:file, :skip_first)

    job = UploadJob.create!(user_id: current_user.id,
                            filename: import_params[:file].path)
    ImportHierarchySpreadsheetJob.perform_later(job.id,
                                                import_params[:skip_first])

    redirect_to job
  end

  collection_action :list, method: :get do
    expires_in 1.hour, public: true
  end
end
