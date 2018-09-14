require 'factory_girl'
require Rails.root.join('test', 'support', 'stub_cas.rb')

def create_dummies(model, *args, count: 1)
  puts "Creating #{count} #{model.to_s.pluralize(count)} records#{" (args: #{args})" if args.any?}..."
  count.times { FactoryGirl.create(model, *args) }
end

namespace :dev do
  desc 'Populate the development DB with dummy records'
  task populate: :environment do
    FactoryGirl.find_definitions

    begin
      User.connection.transaction do
        Support::StubCas.stub_requests do
          create_dummies :user, count: 10
        end

        create_dummies :conference, count: 10
        create_dummies :course, count: 10
        create_dummies :ministry, count: 10
        create_dummies :housing_facility_with_units, count: 10
        create_dummies :family_with_members, count: 10
      end
    rescue ActiveRecord::RecordInvalid => e
      # FactoryGirl randomly selects the day for MealExemptions. If it happens
      # to create a duplicate exemption, just try it again.
      if e.record.is_a?(MealExemption) && e.message =~ /one meal type per day/
        raise
      end
      puts 'Trying again...'
      retry
    end
  end
end
