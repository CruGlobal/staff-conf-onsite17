# Based on
# github.com/CruGlobal/global360/blob/master/app/services/key_services/user.rb
class CasAttributes
  BASE_URL = "#{ENV['CAS_URL']}/api/#{ENV['CAS_ACCESS_TOKEN']}".freeze

  attr_reader :email

  def initialize(email)
    @email = email
  end

  # @example Sample output
  #   {"relayGuid"=>"F167605D-94A4-7121-2A58-8D0F2CA6E026",
  #    "ssoGuid"=>"F167605D-94A4-7121-2A58-8D0F2CA6E026",
  #    "firstName"=>"Joshua",
  #    "lastName"=>"Starcher",
  #    "theKeyGuid"=>"F167605D-94A4-7121-2A58-8D0F2CA6E026",
  #    "email"=>"josh.starcher@cru.org"}
  def get
    JSON.parse(
      RestClient.get(
        "#{BASE_URL}/user/attributes?email=#{CGI.escape(email)}",
        accept: :json
      )
    )
  end
end
