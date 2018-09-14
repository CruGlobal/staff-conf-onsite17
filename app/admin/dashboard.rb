ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard.title') }

  content title: proc { I18n.t('active_admin.dashboard.title') } do
    div class: 'blank_slate_container', id: 'dashboard_default_message' do
      span class: 'blank_slate' do
        span I18n.t('active_admin.dashboard.welcome')
        small I18n.t('active_admin.dashboard.call_to_action')
      end
    end

    panel t('active_admin.dashboard.updated') do
      table_for PaperTrail::Version.order('id desc').limit(20) do
        column('Record') { |v| version_label(v) }
        column :event
        column('When')   { |v| v.created_at.to_s :long }
        column('Editor') { |v| editor_link(v) }
      end
    end
  end
end
