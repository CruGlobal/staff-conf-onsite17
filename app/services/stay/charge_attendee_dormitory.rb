class Stay::ChargeAttendeeDormitory < ChargesService
  attr_accessor :attendee

  def call
    assign_totals(
      Stay::ChargeAttendeeCost.call(attendee: attendee,
                                    housing_type: 'dormitory')
    )
  end
end
