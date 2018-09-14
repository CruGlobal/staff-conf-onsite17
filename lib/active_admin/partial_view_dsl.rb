module ActiveAdmin
  # This class makes it easier to using Rails view partials to specify layout
  # of various Resource pages. It's accessed via
  # {ActiveAdmin::ResourceDSL#partial_view}.
  #
  # The reason this method is used is due to the unusual way in which
  # ActiveAdmin lets you specify page layouts. For example, typically, you can
  # pass a block to +index+ to define what columns are shown in the index
  # table:
  #
  # @example Customize Index Table
  #   index do
  #     id_column
  #     column :image_title
  #     actions
  #   end
  #
  # However, if you instead render a partial in +index+ it will replace the
  # entire contents of the page:
  #
  # @example Index Page Partial
  #   index { render 'my_index_page' }
  #
  # Using this method, you can customize the table index (or the show, form,
  # sidebar, etc) without replacing the entire contents of the page.
  #
  # @see +config/initializers/active_admin_custom.rb+
  class PartialViewDSL
    class << self
      def create_actions(dsl, actions)
        new(dsl).tap do |view_dsl|
          actions.each { |action| add_all_views(view_dsl, action) }
        end
      end

      private

      def add_all_views(view_dsl, action)
        if action.is_a?(Hash)
          action.each { |act, opts| view_dsl.add_view(act, opts) }
        else
          view_dsl.add_view(action)
        end
      end
    end

    def initialize(dsl)
      @dsl = dsl
    end

    def add_view(action, options = nil)
      action = action.to_s
      options = wrap_options(options)

      @dsl.send(action.to_sym, *options, &action_block(action))
    end

    private

    def view_prefix
      @dsl.config.resource_name.route_key
    end

    def wrap_options(options)
      options.is_a?(Hash) ? [options] : Array(options)
    end

    def action_block(action)
      partial = format('%s/%s', view_prefix, action)

      if action == 'form'
        proc { |form| render partial, context: form }
      else
        proc { render partial, context: self }
      end
    end
  end
end
