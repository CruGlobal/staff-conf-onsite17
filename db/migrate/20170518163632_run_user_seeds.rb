require_relative '../user_variables.rb'

class RunUserSeeds < ActiveRecord::Migration
  def change
    SeedUserVariables.new.call unless Rails.env.test?
  end
end
