require_relative './development_records'
require_relative './seminaries'
require_relative './user_variables'

# These seeds must exist, all the time and in every evironment
SeedUserVariables.new.call
SeedSeminaries.new.call

SeedDevelopmentRecords.new.call if Rails.env.development? || Rails.env.staging?
