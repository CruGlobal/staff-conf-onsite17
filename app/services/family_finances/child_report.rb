module FamilyFinances
  class ChildReport < BaseReport
    include ChildcareHelper

    attr_accessor :child

    def_delegator :stays_cost, :total_adjustments, :stay_adjustments
    def_delegator :childcares_cost, :total_adjustments, :childcare_adjustments
    def_delegator :rec_center_cost, :total_adjustments, :rec_center_adjustments
    def_delegator :hot_lunches_cost, :total_adjustments,
                  :hot_lunch_adjustments

    i18n_scope 'family_finances'

    def cost_reports
      [stays_cost, childcares_cost, hot_lunches_cost, rec_center_cost]
    end

    def on_campus_stays
      stay_scope.select(&:on_campus?).map(&method(:stay_row))
    end

    def childcare
      (child.childcare_weeks.map(&method(:childcare_row)) << deposit_charge).compact
    end

    def rec_center
      return [] unless child.rec_pass?

      label = t('rec_pass', start: l(child.rec_pass_start_at, format: :month),
                            finish: l(child.rec_pass_end_at, format: :month))
      Array(row(label, rec_center_cost.total))
    end

    def hot_lunches
      child.hot_lunch_weeks.map(&method(:hot_lunch_row))
    end

    private

    def stay_row(stay)
      cost = Stay::SingleChildDormitoryCost.call(child: child, stay: stay)
      row(stay.to_s, cost.total)
    end

    def childcare_row(index)
      row(childcare_weeks_label(index), childcares_cost.sum.week_charges[index])
    end

    def hot_lunch_row(index)
      row(childcare_weeks_label(index),
          hot_lunches_cost.sum.week_charges[index])
    end

    def stay_scope
      child.stays.not_in_self_provided
    end

    def stays_cost
      @stays_cost ||= Stay::ChargeChildCost.call(child: child)
    end

    def childcares_cost
      @childcares_cost ||=
        if child.age_group == :childcare
          Childcare::ChargeChildCost.call(child: child)
        else
          JuniorSenior::ChargeChildCost.call(child: child)
        end
    end

    def deposit_charge
      if child.childcare_deposit?
        row(t('childcare_deposit'), childcares_cost.sum.deposit_charge)
      end
    end

    def rec_center_cost
      @rec_center_cost ||= RecPass::ChargePersonCost.call(person: child)
    end

    def hot_lunches_cost
      @hot_lunches_cost ||= HotLunch::ChargeChildCost.call(child: child)
    end
  end
end
