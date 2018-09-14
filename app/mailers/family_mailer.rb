class FamilyMailer < ApplicationMailer
  DEFAULT_EMAIL = 'josh.starcher@cru.org'.freeze

  add_template_helper(ApplicationHelper)
  add_template_helper(CostAdjustmentHelper)
  add_template_helper(PaymentHelper)

  def summary(family)
    @family = family
    @finances = FamilyFinances::Report.call(family: family)

    # Send email with the rights of a finance user
    finance_user = User.find_by(role: 'finance')
    @policy = Pundit.policy(finance_user, family)

    emails =
      if Rails.env.production?
        family.attendees.pluck(:email).select(&:present?).compact
      else
        DEFAULT_EMAIL
      end
    mail(to: emails, subject: 'Cru17 Financial Summary')
  end

  def media_release(family)
    @family = family

    emails =
      if Rails.env.production?
        family.attendees.pluck(:email).select(&:present?).compact
      else
        DEFAULT_EMAIL
      end
    mail(to: emails,
         from: 'cru17.mediaReleases@cru.org',
         subject: 'IMPORTANT: Please Read')
  end
end
