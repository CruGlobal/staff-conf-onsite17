# This {Concern} marks up a {ActiveModel::Model} so that it can be used as a
# collection of records for an ActiveAdmin +#index+ page (which normally only
# allows {ActiveRecord}).  Implementing classes must define two methods:
#
#  * +Class#columns+: return a list of +Columns+ to show in the table
#  * +#each+: to enumerate over each record
#  * +#total_count+: return the total number of records (ie: no pagination)
#
# Each item returned by +#each+ should...:
#
#  * Implement +#id+. It's value can be anything, but it must be something.
#  * Extend {ActiveModel::Serializers::Xml} and implement +#attributes+. This
#    method should return a Hash of attribute names and their values.
module ActiveModelResourceCollection
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Serializers::Xml

    attr_writer :current_page, :limit_value
  end

  class_methods do
    def column_names
      [primary_key] + columns.map(&:name)
    end

    def content_columns
      columns
    end

    def primary_key
      :id
    end

    def inheritance_column
      nil
    end

    protected

    # Helper factory for +Column" objects
    # @param name [#to_s] the name of the column
    # @param type [#to_s] the column's data type
    # @param default [#to_s] the column's default value, if any
    def column(name, type, default: nil)
      klass = "ActiveRecord::Type::#{type.to_s.camelize}".constantize
      ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, klass)
    end
  end

  def page(new_page)
    self.current_page = new_page&.to_i
    self
  end

  def per(new_per)
    self.limit_value = new_per&.to_i
    self
  end

  def current_page
    @current_page || 1
  end

  def limit_value
    @limit_value || 1
  end

  def total_pages
    [1, total_count / limit_value].max
  end

  def except(*_opts)
    self
  end

  def group_values
    nil
  end

  def attributes
    { rows: each.to_a }
  end
end
