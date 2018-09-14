module AccountingReport
  class ChildStayNonTaxableCosts < HelperBase
    def description_label
      'Jr/Sr Rm&Bd'
    end

    protected

    def bus_debit_attributes
      {
        bus_unit: business_account_payment.business_unit,
        oper_unit: business_account_payment.operating_unit,
        dept_id: business_account_payment.department_code,
        project: business_account_payment.project_code,
        account: 67620,
        product: 'Ext',
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
        product: 'Ext',
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
        account: 67620,
        product: 'Ext',
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
        product: 'Ext',
        amount: -staff_amount,
        reference: ''
      }
    end

    def total_cost
      @total_cost ||=
        children.inject(Money.empty) do |sum, child|
          sum + Stay::ChargeChildCost.call(child: child).total
        end
    end

    def children
      family.children.includes(:childcare_weeks).select do |child|
        child.age_group != :childcare && child.childcare_weeks.any?
      end
    end
  end
end
