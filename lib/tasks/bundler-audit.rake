require 'bundler/audit/cli'

namespace :bundle do
  desc 'Updates the ruby-advisory-db then runs bundle-audit'

  task :audit do
    ignored =
      File.open(Rails.root.join('.bundle-audit-ignored')).
        each_line.
        map { |line| line.sub(/#.+/, '').strip }.
        select(&:present?).
        map { |ignore| ['-i', ignore] }

    Bundler::Audit::CLI.start(['update'])
    Bundler::Audit::CLI.start((['check'] + ignored).flatten)
  end
end
