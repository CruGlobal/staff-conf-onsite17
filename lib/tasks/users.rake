namespace :users do
  desc 'Create a new admin user with the given email address'
  task :new_admin, [:email] => :environment do |_t, args|
    user = User.create!(role: 'admin', email: args.email)
    puts "Created: #{user.inspect}"
  end
end
