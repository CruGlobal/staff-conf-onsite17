class SeedSeminaries
  RECORDS = {
    IBS: { name: 'IBS' }
  }.freeze

  def initialize
    @existing = UserVariable.keys
  end

  def call
    RECORDS.each { |code, attributes| create_unless_exists(code, attributes) }
  end

  private

  def create_unless_exists(code, attributes = {})
    Seminary.find_or_create_by!(code: code) { |s| s.assign_attributes(attributes) }
  end
end
