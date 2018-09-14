module Import
  class HousingUnit
    include ActiveModel::Model
    include ActiveRecord::AttributeAssignment

    attr_accessor :row, :facility_name, :name, :occupancy_type, :room_type

    def self.from_array(row, arr)
      new(
        row: row,
        facility_name: arr[0],
        name: arr[1],
        occupancy_type: arr[2],
        room_type: arr[3]
      )
    end

    def exists_in?(facility)
      facility.housing_units.any? { |unit| unit.name == name }
    end

    def build_record(facility)
      ::HousingUnit.new(
        housing_facility_id: facility.id,
        name: name,
        occupancy_type: occupancy_type,
        room_type: room_type
      )
    end
  end
end
