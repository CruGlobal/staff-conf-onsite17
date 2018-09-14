module AccountingReport
  class AttendeeCosts < HelperBase
    def description_label
      'Adult Charges'
    end

    protected

    def bus_debit_attributes
      {
        bus_unit: business_account_payment.business_unit,
        oper_unit: business_account_payment.operating_unit,
        dept_id: business_account_payment.department_code,
        project: business_account_payment.project_code,
        account: 67520,
        product: 'Int',
        amount: bus_amount,
        reference: business_account_payment.reference
      }
    end

    def bus_credit_attributes
      {
        bus_unit: 'PRESO',
        oper_unit: 'LH',
        dept_id: 'CSU',
        project: '',
        account: 41100,
        product: 'Int',
        amount: -bus_amount,
        reference: ''
      }
    end

    def staff_debit_attributes
      {
        bus_unit: 'STFFD',
        oper_unit: 'LH',
        dept_id: 'STAFF',
        project: '',
        account: 67520,
        product: 'Int',
        amount: staff_amount,
        reference: family.staff_number
      }
    end

    def staff_credit_attributes
      {
        bus_unit: 'PRESSO',
        oper_unit: 'LH',
        dept_id: 'CSU',
        project: '',
        account: 41100,
        product: 'Int',
        amount: -staff_amount,
        reference: ''
      }
    end

    def total_cost
      @total_cost ||=
        family.attendees.inject(Money.empty) do |current_sum, attendee|
          [
            current_sum,
            Stay::ChargeAttendeeCost.call(attendee: attendee).total,
            Course::ChargeAttendeeCost.call(attendee: attendee).total,
            StaffConference::ChargeAttendeeCost.call(attendee: attendee).total,
            Conference::ChargeAttendeeCost.call(attendee: attendee).total,
            RecPass::ChargePersonCost.call(person: attendee).total,
            FacilityUseFee::ChargeAttendeeCost.call(attendee: attendee).total
          ].sum
        end
    end
  end
end
