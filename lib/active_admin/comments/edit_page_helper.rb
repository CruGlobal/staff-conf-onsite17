module ActiveAdmin
  module Comments
    # Adds #active_admin_comments to the edit page for use and sets it up on
    # the main content
    module EditPageHelper
      def self.included(base)
        base.alias_method_chain(:main_content, :comments)
      end

      # Add admin comments to the main content if they are
      # turned on for the current resource
      def main_content_with_comments
        main_content_without_comments
        active_admin_comments_for(resource) if active_admin_config.comments?
      end
    end
  end
end
