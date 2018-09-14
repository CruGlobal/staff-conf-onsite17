module ActiveAdmin
  # Marks up an ActiveAdmin Resource so that it can be reordered with the
  # ActsAsList gem.
  module ActsAsList
    module_function

    def setup
      ::ActiveAdmin::ResourceDSL.send(:include, ControllerActions)
    end

    # Methods to add to the ResourceDSL
    module ControllerActions
      def acts_as_list(attr = :position)
        config.sort_order = "#{attr}_asc"

        member_action :reposition, method: :patch do
          resource.insert_at(params[attr].to_i)
          head :ok
        end
      end
    end
  end
end
