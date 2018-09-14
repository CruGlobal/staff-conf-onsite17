class Stay::SumFamilyAttendeesApartmentCost < ChargesService
  attr_accessor :family

  def call
    assign_totals(
      Stay::SumFamilyAttendeesCost.call(family: family,
                                        housing_type: 'apartment')
    )
  end
end
