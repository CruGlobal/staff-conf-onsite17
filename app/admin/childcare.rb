ActiveAdmin.register Childcare do
  acts_as_list

  partial_view :index, :show, :form
  permit_params :name, :teachers, :location, :room

  filter :name
  filter :location
  filter :room
  filter :created_at
  filter :updated_at

  sidebar 'Sign-In Sheets', only: :show do
    dl do
      Childcare::CHILDCARE_WEEKS.each_with_index do |_, index|
        dt childcare_weeks_label(index)
        dd do
          span link_to 'Portrait', params.merge(action: :signin_portrait, week: index)
          span link_to 'Landscape', params.merge(action: :signin_landscape, week: index)
          span link_to 'Roster', params.merge(action: :roster, week: index)
          span link_to 'Car Line', params.merge(action: :car_line, week: index)
        end
      end
    end
  end

  sidebar 'Sign-In Sheets', only: :index do
    dl do
      Childcare::CHILDCARE_WEEKS.each_with_index do |_, index|
        dt childcare_weeks_label(index)
        dd do
          span link_to 'Portrait', params.merge(action: :signin_portraits, week: index)
          span link_to 'Landscape', params.merge(action: :signin_landscapes, week: index)
          span link_to 'Roster', params.merge(action: :rosters, week: index)
          span link_to 'Car Line', params.merge(action: :car_lines, week: index)
        end
      end
    end
  end

  collection_action :signin_portraits do
    if week_param.present?
      roster = AggregatePdfService.call(Childcare::Signin::Portrait, collection,
                                        key: :childcare, week: week_param,
                                        author: current_user)
      send_data(roster.render, type: 'application/pdf', disposition: :inline)
    else
      redirect_to_invalid_week
    end
  end

  collection_action :signin_landscapes do
    if week_param.present?
      roster = AggregatePdfService.call(Childcare::Signin::Landscape,
                                        collection,
                                        key: :childcare, week: week_param,
                                        author: current_user)
      send_data(roster.render, type: 'application/pdf', disposition: :inline)
    else
      redirect_to_invalid_week
    end
  end

  collection_action :rosters do
    if week_param.present?
      roster = AggregatePdfService.call(Childcare::Roster, collection,
                                        key: :childcare, week: week_param,
                                        author: current_user)
      send_data(roster.render, type: 'application/pdf', disposition: :inline)
    else
      redirect_to_invalid_week
    end
  end

  collection_action :car_lines do
    if week_param.present?
      roster = Childcare::Signin::CarLine.call(childcares: collection,
                                               week: week_param,
                                               author: current_user)
      send_data(roster.render, type: 'application/pdf', disposition: :inline)
    else
      redirect_to_invalid_week
    end
  end

  member_action :signin_portrait do
    if week_param.present?
      roster =
        Childcare::Signin::Portrait.call(childcare: Childcare.find(params[:id]),
                                         week: week_param, author: current_user)
      send_data(roster.render, type: 'application/pdf', disposition: :inline)
    else
      redirect_to_invalid_week
    end
  end

  member_action :signin_landscape do
    if week_param.present?
      roster =
        Childcare::Signin::Landscape.call(
          childcare: Childcare.find(params[:id]), week: week_param,
          author: current_user
        )
      send_data(roster.render, type: 'application/pdf', disposition: :inline)
    else
      redirect_to_invalid_week
    end
  end

  member_action :roster do
    if week_param.present?
      roster = Childcare::Roster.call(childcare: Childcare.find(params[:id]),
                                      week: week_param, author: current_user)

      send_data(roster.render, type: 'application/pdf', disposition: :inline)
    else
      redirect_to_invalid_week
    end
  end

  member_action :car_line do
    if week_param.present?
      roster = Childcare::Signin::CarLine.call(childcares: Childcare.find(params[:id]),
                                               week: week_param,
                                               author: current_user)
      send_data(roster.render, type: 'application/pdf', disposition: :inline)
    else
      redirect_to_invalid_week
    end
  end

  controller do
    def week_param
      week = params[:week]&.to_i
      week if Childcare::CHILDCARE_WEEKS.size.times.to_a.include?(week)
    end

    def redirect_to_invalid_week
      redirect_to childcare_path(params[:id]),
                  alert: format('Invalid week of childcare %p', params[:week])
    end
  end
end
