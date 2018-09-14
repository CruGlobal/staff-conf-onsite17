module Support
  module Authentication
    def assert_permit(user, record, action)
      msg = "User #{user.inspect} should be permitted to #{action} #{record.inspect}, but isn't permitted"
      assert permit(user, record, action), msg
    end

    def refute_permit(user, record, action)
      msg = "User #{user.inspect} should NOT be permitted to #{action} #{record.inspect}, but is permitted"
      refute permit(user, record, action), msg
    end

    def permit(user, record, action)
      cls = self.class.to_s.gsub(/Test/, 'Policy')
      cls.constantize.new(user, record).public_send("#{action.to_s}?")
    end

    def create_users
      @general_user ||= create :general_user
      @finance_user ||= create :finance_user
      @admin_user ||= create :admin_user
      @read_only_user ||= create :read_only_user
    end

    # Asserts that +only+ cetain {User::ROLES user roles} have permission to
    # modify the given +resource+. User roles not given in +only+ will be
    # checked to ensure they are denied access.
    #
    # @param [Symbol] action The requested action
    # @param [Object] resource The requested object to be accessed
    # @param [Array<Symbol] only The list of user roles allowed to modify the
    #   given +resource+
    def assert_accessible(action, resource, only: [])
      create_users
      roles = User::ROLES.map(&:to_sym)
      users = Hash[roles.map { |r| [r, instance_variable_get("@#{r}_user")] }]

      permit_users = Array(only).map { |role| users[role] }
      permit_users.each { |user| assert_permit user, resource, action }

      refute_users = users.values - permit_users
      refute_users.each { |user| refute_permit user, resource, action }
    end

    # Create a new user record and set them as logged in.
    def create_login_user(role = nil)
      create("#{role || :admin}_user").tap { |u| login_user(u) }
    end

    # Updates the session for the Capybara user agent to login the given user.
    def login_user(user)
      # {#set_rack_session} comes from the 'rack_session_access' gem
      page.set_rack_session('cas' => {
        'user' => user.email,
        'extra_attributes' => {
          'email' => user.email,
          'first_name' => user.first_name,
          'last_name' => user.last_name,
          'ssoGuid' => user.guid
        }
      })
    end
  end
end
