namespace :populate do
  desc 'Populate the database with default Seminary records'
  task default_seminaries: :environment do
    [
      ['IBS', 'IBS', 0],
      ['Bethel Theological Seminary', 'BTS'],
      ['Dallas Theological Seminary', 'DTS'],
      ['Reformed Theological Seminary', 'RTS'],
      ['Trinity Evangelical Divinity School', 'TIU'],
      ['Talbot School of Theology', 'TST']
    ].each do |seminary|
      price = Money.new(seminary[2] || 9000)
      s = Seminary.create(
        name: seminary[0],
        code: seminary[1],
        course_price: price
      )
      puts "Created: #{s.name} (#{s.code}) - #{s.course_price}"
    end

    Attendee.
      where(seminary_id: nil).
      update_all(seminary_id: Seminary.default.id)
  end
end
