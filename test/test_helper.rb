ENV['RAILS_ENV'] ||= 'test'

# Must appear before the Application code is required
require 'simplecov'
SimpleCov.start

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'webmock/minitest'
require 'minitest/rails/capybara'
require 'rack_session_access/capybara'
require 'minitest/reporters'
require_relative '../db/seminaries'

Minitest::Reporters.use!

Dir[Rails.root.join("test/support/**/*.rb")].each { |f| require f }

Support::StubCas.stub_requests
FactoryGirl.find_definitions

class ControllerTestCase < ActionController::TestCase
  include FactoryGirl::Syntax::Methods
  include Support::UserVariable
end

class IntegrationTest < Capybara::Rails::TestCase
  include FactoryGirl::Syntax::Methods
  include Support::ActiveAdmin
  include Support::Authentication
  include Support::Javascript
  include Support::UserVariable

  self.use_transactional_fixtures = false
  before(:each) do
    DatabaseCleaner.strategy = :truncation, { pre_count: true, reset_ids: false }
    DatabaseCleaner.start
  end
  after(:each) do
    Capybara.use_default_driver
    DatabaseCleaner.clean
  end
end

class ModelTestCase < ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  include Support::Authentication
  include Support::Moneyable
  include Support::UserVariable

  self.use_transactional_fixtures = false
  before(:each) do
    DatabaseCleaner.strategy = :truncation, { pre_count: true, reset_ids: false }
    DatabaseCleaner.start
  end
  after(:each)  { DatabaseCleaner.clean }
end

class ServiceTestCase < ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  include Support::UserVariable
  include ActionDispatch::TestProcess

  self.use_transactional_fixtures = false
  before(:each) do
    DatabaseCleaner.strategy = :truncation, { pre_count: true, reset_ids: false }
    DatabaseCleaner.start
  end
  after(:each)  { DatabaseCleaner.clean }
end
