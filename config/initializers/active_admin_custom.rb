# This initializer includes ActiveAdmin customization beyond the out-of-the-box
# configuration.

# Add extra buttons to the #show page
ActiveAdmin::Resource.include(ActiveAdmin::Resource::AdditionalActionItems)

# Show comments form on #edit pages too
require 'active_admin/comments/edit_page_helper'
ActiveAdmin.application.view_factory.edit_page.send(
  :include, ActiveAdmin::Comments::EditPageHelper
)

# Easily Allow view partial files to render Resource actions
# @see +lib/active_admin/partial_view_dsl.rb+
Rails.configuration.to_prepare do
  ActiveAdmin::ResourceDSL.class_eval do
    def partial_view(*actions)
      ActiveAdmin::PartialViewDSL.create_actions(self, actions)
    end
  end
end

# Allows users to reorder records
# @see +lib/active_admin/acts_as_list.rb+
ActiveAdmin::ActsAsList.setup
