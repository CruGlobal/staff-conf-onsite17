require 'webmock'

module Support
  # Stub out HTTP requests to the remote CAS service, for testing / development.
  # If an email address is provided in the request (the typical cas), we return
  # that email address as the user's GUID.
  class StubCas
    include WebMock::API

    DOMAIN_RE = /thekey\.me/

    # Stub out requests to the remote CAS service. If a block is provided,
    # requests are only stubbed for the duration of the block.
    def self.stub_requests(&blk)
      new.call

      if blk
        blk.call
        WebMock.disable!
      end
    end

    def call
      WebMock.disable_net_connect!(allow_localhost: true)
      WebMock.enable!

      stub_request(:get, DOMAIN_RE).to_return do |req|
        if (email = req.uri.query_values['email'])
          {status: 201, body: "{\"ssoGuid\": \"#{email}\"}"}
        else
          {status: 201, body: '{}'}
        end
      end
    end

    def login_user(user)
      visit root_path
      fill_in 'username', with: 'johndoe'
      fill_in 'password', with: 'any password'
      click_button 'Login'
    end
  end
end
