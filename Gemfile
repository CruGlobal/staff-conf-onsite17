source 'https://rubygems.org'
source 'https://gems.contribsys.com/' do
  gem 'sidekiq-pro'
end

# Server
gem 'good_migrations', '~> 0.0.2'
gem 'newrelic_rpm', '~> 4.0'
gem 'pg', '~> 0.19.0'
gem 'puma', '~> 3.0'
gem 'syslog-logger', '~> 1.6.8'

# Background Processes
gem 'redis-namespace', '~> 1.5'
gem 'redis-objects', '~> 0.6'
gem 'redis-rails', '~> 5.0'
gem 'sidekiq-cron'
gem 'sidekiq-unique-jobs'

# Error Reporting
gem 'oj', '~> 2.18'
gem 'rollbar', '~> 2.14'

# Framework
gem 'activeadmin', '~> 1.0.0'
gem 'acts_as_list', '~> 0.9'
gem 'paper_trail', '~> 5.2.2'
gem 'rails', '~> 4.2'
gem 'roo', '~> 2.7'

# Authentication
gem 'pundit', '~> 1.1.0'
gem 'rack-cas', '~> 0.15.0'
gem 'rest-client', '~> 2.0.0'

# Assets
gem 'coffee-rails', '~> 4.1.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'

# View Helpers
# TODO: gem 'activeadmin-axlsx', '>= 2.2' when compatible with activeadmin-1.0.0
# TODO: and remove the version in ./lib/active_admin/
gem 'axlsx', '~> 2.1.0.pre'
gem 'chosen-rails', '~> 1.5.2'
gem 'compass-rails', '~> 3.0'
gem 'countries', '~> 1.2.5'
gem 'money-rails', '~> 1.7'
gem 'phone', '~> 1.2.3'
gem 'prawn', '~> 2.2'
gem 'prawn-table', '~> 0.2'
gem 'truncate_html', '~> 0.9.3'

# Frontend Scripts
gem 'ckeditor_rails', '~> 4.6'
gem 'intl-tel-input-rails', '~> 8.4.9'
gem 'jquery-rails', '~> 4.2'
gem 'jquery-ui-rails', '~> 5.0'
gem 'turbolinks', '~> 5.0.1'

# We don't require Nokogiri directly, only through other gems (like axlsx).
# However, due to CVE-2016-4658, we need to ensure we're using at least v1.7.1.
#
# TODO: remove this line after dependent gems update to this version of Nokogiri
gem 'nokogiri', '>= 1.7.1'

group :development, :test do
  gem 'dotenv-rails', '~> 2.1.1'

  # Testing
  gem 'bundler-audit', '~> 0.5'           # Linter
  gem 'byebug', '~> 9.0'                  # Debugger
  gem 'coffeelint', '~> 1.16'             # Coffeescript Linter
  gem 'database_cleaner', '~> 1.5'        # Truncates the DB after each test
  gem 'factory_girl', '~> 4.7'            # Test object factories
  gem 'faker', '~> 1.6'                   # Fake data generator
  gem 'guard', '~> 2.14'                  # Continuous testing
  gem 'guard-minitest', '~> 2.4'          # ""
  gem 'minitest-around', '~> 0.4'         # Minitest around callback
  gem 'minitest-rails-capybara', '~> 2.1' # Integration tests
  gem 'minitest-reporters', '~> 1.1'      # Test output format
  gem 'pry-rails', '~> 0.3.5'
  gem 'rack_session_access', '~> 0.1'     # Edit user-agent session
  gem 'reek', '~> 4.7'                    # Linter
  gem 'rubocop', '~> 0.50'                # Linter
  gem 'selenium-webdriver', '~> 3.2'      # Integration tests javascript support
  gem 'simplecov', '~> 0.15',             # test coverage
      require: false
  gem 'webmock', '~> 2.1'                 # Stub HTTP requests

  # Documentation
  gem 'yard', '~> 0.9.5'
end

group :development do
  # Development Server
  gem 'spring'
  gem 'web-console', '~> 2.0'

  # Deployment
  # TODO gem 'capistrano-rails'
end
