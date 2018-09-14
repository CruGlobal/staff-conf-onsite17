ActiveAdmin.register Report do
  partial_view :index, :show
  permit_params :category, :name, :query, :role

  filter :category, as: :select
  filter :name

  config.sort_order = 'name_asc'

  member_action :download, method: :get do
    report = Report.find(params[:id])
    date = Time.zone.today

    send_data(report.to_csv, filename: "#{report.name}-#{date}.csv")
  end
end
