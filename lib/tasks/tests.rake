# These tasks are redefined below
%w[default test test:integration].each do |t|
  Rake.application.instance_variable_get('@tasks').delete(t)
end

desc 'Run the entire suit of tests and linters'
task :default do
  border = '=' * 80
  tasks = %w[test:unit test:integration rubocop reek bundle:audit coffeelint]

  puts "The following Rake tasks will be run: #{tasks.to_sentence}"
  tasks.each do |task|
    puts "\n#{border}\nRunning `rake #{task}`\n#{border}"
    Rake::Task[task].invoke
  end
  puts 'Success.'
end

Rake::TestTask.new('test:unit') do |t|
  t.pattern = 'test/{controllers,lib,models,interactors}/**/*_test.rb'
  t.description = 'Run quicker unit tests'
  t.libs << 'test'
  t.warning = false
  t.verbose = true
end

Rake::TestTask.new('test:integration') do |t|
  t.pattern = 'test/integration/**/*_test.rb'
  t.description = 'Run slower integration tests'
  t.libs << 'test'
  t.warning = false
  t.verbose = true
end

desc 'Run unit tests and then integration tests'
task test: %i[test:unit test:integration]
