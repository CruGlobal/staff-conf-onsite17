module ActiveAdmin
  class Resource
    # @see https://github.com/activeadmin/activeadmin/blob/master/lib/active_admin/resource/action_items.rb
    module AdditionalActionItems
      def initialize(*args)
        add_additional_action_items_before
        super
        add_additional_action_items_after
      end

      protected

      def add_additional_action_items_before
        add_additional_new_action_item
      end

      def add_additional_action_items_after
        add_paper_trail_history_item
      end

      private

      # Adds the default New link on :show. Normally it's only on :index.
      def add_additional_new_action_item
        add_action_item :new_show, only: :show do
          permitted =
            authorized? ActiveAdmin::Auth::CREATE,
                        active_admin_config.resource_class

          if controller.action_methods.include?('new') && permitted
            link_to(
              I18n.t(
                'active_admin.new_model',
                model: active_admin_config.resource_label
              ),
              new_resource_path
            )
          end
        end
      end

      def add_paper_trail_history_item
        add_action_item :paper_trail, only: :show, &PAPER_TRAIL_ACTION
      end

      PAPER_TRAIL_ACTION = proc do
        permitted =
          authorized?(ActiveAdmin::Auth::READ, PaperTrail::Version)

        klass = active_admin_config.resource_class

        if permitted && klass.paper_trail.enabled?
          link_to(
            I18n.t('activerecord.models.paper_trail.version.other'),
            paper_trail_versions_path(
              q: {
                item_type_eq: resource.class.base_class.name,
                item_id_eq: resource.id
              }
            )
          )
        end
      end
    end
  end
end
