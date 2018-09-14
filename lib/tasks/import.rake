def df(date, row)
  Date.strptime(date, '%m/%d/%Y')
rescue StandardError => e
  puts e.message
  raise row.inspect
end

namespace :import do
  desc 'Import housing assignments from spreadsheet'
  task housing: :environment do
    table = CSV.table(Rails.root.join('tmp', 'june-4-17-assignments.csv'))
    missing_rooms = []
    missing_people = []

    FACILITIES = {
      'corbett' => HousingFacility.find_by(name: 'Corbett (suite style, no A/C)'),
      'laurel village-alpine suites' => HousingFacility.find_by(name: 'Alpine (suite style, with A/C)'),
      'laurel village-alpine traditional' => HousingFacility.find_by(name: 'Alpine (community bathroom with A/C)'),
      'laurel villiage-alpine traditional' => HousingFacility.find_by(name: 'Alpine (community bathroom with A/C)'),
      'laurel village-pinon traditional' => HousingFacility.find_by(name: 'Pinon (community bathroom with A/C)'),
      'laurel village-pinon private' => HousingFacility.find_by(name: 'Pinon (private bathroom, with A/C)'),
      'laurel village-pinon suites' => HousingFacility.find_by(name: 'Pinon (suite style, with A/C)'),
      'westfall' => HousingFacility.find_by(name: 'Westfall (community bathroom, no A/C)')
    }.freeze

    table.each do |row|
      next unless row[:block]
      raise row.inspect unless row[:arrival_date] && row[:departure_date] # && row[:first_name] && row[:last_name]
      facility_name = FACILITIES[row[:block].to_s.downcase]
      raise row.inspect unless facility_name

      person = Person.find_by('lower(email) = ?', row[:email])

      person ||= Person.where('lower(first_name) = ? AND lower(last_name) = ?',
                              row[:first_name].to_s.strip.downcase,
                              row[:last_name].strip.downcase).first

      unless person
        missing_people << "#{row[:first_name]} #{row[:last_name]}"
        next
      end

      room_name = row[:room_name].split(' ').last.sub(/(\w?\d+)\w?/, '\1')

      room = HousingUnit.find_by(housing_facility_id: FACILITIES[row[:block].downcase], name: room_name)
      raise row[:block].inspect unless FACILITIES[row[:block].downcase]
      unless room
        missing_rooms << row[:room_name]
        # raise row.inspect
        next
      end

      notes = ''
      notes += "#{row[:license_plate]}\n" if row[:license_plate].present?
      notes += "#{row[:notes]}\n"

      stay =
        person.stays.where(
          arrived_at: df(row[:arrival_date], row),
          departed_at: df(row[:departure_date], row)
        ).first_or_initialize
      stay.housing_unit_id = room.id
      stay.comment = notes
      stay.save!
    end
    puts "Wrong rooms: #{missing_rooms.uniq.join(', ')}"
    puts "Missing people: #{missing_people.join(', ')}"
  end

  def facility_lookup(name, apt, rooms)
    facility_name = ''
    case name.downcase
    when 'aggie village'
      a = 'Aggie Village - '
      b = apt.split(' ').first
      c = rooms.to_s.casecmp('studio').zero? ? 'Studio' : "#{rooms} Bedroom"
      facility_name = "#{a}#{b} #{c}"
    when 'rams park'
      facility_name = "Rams Park #{rooms} Bedroom"
    when "ram's village"
      a = 'Rams Village '
      b = apt.split(' ').first
      facility_name = "#{a}#{b} #{rooms} Bedroom"
    when 'state on campus'
      facility_name = "State on Campus #{rooms} Bedroom"
    when 'university village'
      facility_name = "University Village #{rooms} Bedroom"
    else
      puts "No clue: #{name} -> #{apt} -> #{rooms}"
    end
    HousingFacility.find_by(name: facility_name)
  end

  task apartments: :environment do
    table = CSV.table(Rails.root.join('tmp', 'apartments.csv'))
    missing_apts = []

    table.each do |row|
      next unless row[:complex]
      raise row.inspect unless row[:arrive] && row[:depart] # && row[:first_name] && row[:last_name]
      facility = facility_lookup(row[:complex].to_s, row[:assigned_apt], row[:assigned_brs])
      raise row.inspect unless facility

      family = Family.find_by('lower(import_tag) = ?', row[:group_id].downcase) if row[:group_id].present?
      family ||=
        Person.joins(:family).
          where('((lower(first_name) = :first AND lower(people.last_name) = :last) OR
                 (lower(name_tag_last_name) = :last AND lower(name_tag_first_name) = :first))',
                first: row[:first].to_s.strip.downcase, last: row[:last].strip.downcase).
          first.
          try(:family)

      person = family.primary_person || family.people.order(:birthdate).first if family

      unless person
        msg = "Couldn't find: #{row[:first]} #{row[:last]} "
        puts msg
        next
      end

      apt_name = row[:assigned_apt].to_s.split(' ').last
      apt_name =
        case row[:complex]
        when "Ram's Village"
          apt_name.sub(/(\w)(\d+)/, '\1-\2')
        when 'University Village'
          apt_name.sub(/(\d+)(\w)/, '\1-\2')
        end

      apt = facility.housing_units.find_by(name: apt_name)
      unless apt
        # raise row.inspect
        missing_apts << row[:assigned_apt]
        next
      end

      stay = person.stays.where(
        arrived_at: df(row[:arrive], row),
        departed_at: df(row[:depart], row)
      ).first_or_initialize
      stay.housing_unit_id = apt.id
      stay.save! if stay.changed?
    end
    puts "Missing apts: #{missing_apts.join(', ')}"
  end

  desc 'Import comments'
  task comments: :environment do
    table = CSV.table(Rails.root.join('tmp', 'export.csv'))
    table.each do |row|
      if row[:housing_comments].to_s.length >= 255
        family = Family.find_by(import_tag: row[:family])
        if family.housing_preference.comment.length == 255
          family.housing_preference.update!(comment: row[:housing_comments])
        end
      end
      columns = {
        mobility_needs_comment: :mobility_comment,
        personal_comments: :personal_comment,
        conference_comments: :conference_comment,
        childcare_comments: :childcare_comment,
        ibs_comments: :ibs_comment
      }
      columns.each do |key, db_column|
        next unless row[key].to_s.length >= 255

        family = Family.find_by(import_tag: row[:family])
        next unless family

        person = family.people.find_by(first_name: row[:first],
                                       last_name: row[:last])
        raise row.inspect unless person

        next unless person.send(db_column).length == 255

        person.update!(db_column => row[key])
        puts row[key]
        puts person.id
        puts key
      end
    end
  end

  desc 'Import Single room requested'
  task single: :environment do
    table = CSV.table(Rails.root.join('tmp', 'export.csv'))

    table.each do |row|
      next unless row[:single_room_requested].to_s == 'Yes'

      family = Family.find_by(import_tag: row[:family])
      puts row.inspect unless family
      family.housing_preference.update!(single_room: true)
    end
  end
end
