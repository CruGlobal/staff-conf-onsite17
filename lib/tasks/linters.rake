# Custom default Rake task to handle code analysis and testing
require 'rubocop/rake_task'
RuboCop::RakeTask.new

require 'reek/rake/task'
Reek::Rake::Task.new
