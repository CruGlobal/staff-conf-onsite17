require 'active_support/core_ext/string'

guard :minitest, all_on_start: false do
  watch(%r{^test/.+_test\.rb$})

  # Unit tests
  watch(%r{^app/(.+)\.rb$})                               { |m| "test/#{m[1]}_test.rb" }
  watch(%r{^app/controllers/application_controller\.rb$}) { 'test/controllers' }
  watch(%r{^app/controllers/(.+)_controller\.rb$})        { |m| "test/integration/#{m[1]}_test.rb" }
  watch(%r{^app/services/(.+)\.rb$})                      { |m| "test/services/#{m[1]}_test.rb" }
  watch(%r{^lib/(.+)\.rb$})                               { |m| "test/lib/#{m[1]}_test.rb" }

  # Integration tests
  watch(%r{^app/admin/(.+).rb$})         { |m| Dir["test/integration/#{m[1]}/*_test.rb"] }
  watch(%r{^app/views/([^/]+)/.+\.arb$}) { |m| Dir["test/integration/#{m[1].singularize}/*_test.rb"] }
end
