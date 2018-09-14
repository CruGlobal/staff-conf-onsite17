ActiveAdmin.register Family do
  includes :attendees, :housing_preference

  partial_view(
    :index,
    show: { title: ->(f) { family_label(f) } },
    form: { title: ->(f) { f.new_record? ? 'New Family' : "Edit #{family_label(f)}" } },
    sidebar: ['Family Members', only: [:edit]]
  )

  menu parent: 'People', priority: 1

  permit_params :last_name, :staff_number, :address1, :address2, :city, :state,
                :zip, :country_code, :primary_person_id, :license_plates, :handicap,
                housing_preference_attributes: %i[
                  id housing_type roommates beds_count single_room
                  children_count bedrooms_count other_family
                  accepts_non_air_conditioned location1 location2 location3
                  confirmed_at comment
                ],
                people_attributes: [:id, { stays_attributes: %i[
                  id _destroy housing_unit_id arrived_at departed_at
                  single_occupancy no_charge waive_minimum percentage comment
                  no_bed
                ] }]

  filter :last_name
  filter :attendees_first_name, label: 'Attendee Name', as: :string
  filter :staff_number
  filter :address1
  filter :address2
  filter :city
  filter :state
  filter :country_code, as: :select, collection: -> { country_select }
  filter :zip
  filter :created_at
  filter :updated_at

  collection_action :new_spreadsheet, title: 'Import Spreadsheet'
  action_item :import_spreadsheet, only: :index do
    if authorized?(:import, Family)
      link_to 'Import Spreadsheet', action: :new_spreadsheet
    end
  end

  collection_action :import_spreadsheet, method: :post do
    return head :forbidden unless authorized?(:import, Family)

    import_params =
      ActionController::Parameters.new(params).require(:import_spreadsheet).
        permit(:file)

    job = UploadJob.create!(user_id: current_user.id,
                            filename: import_params[:file].path)
    ImportPeopleFromSpreadsheetJob.perform_later(job.id)

    redirect_to job
  end

  action_item :accounting_report, only: %i[show edit] do
    link_to 'Accounting Report', family_accounting_reports_path(family)
  end

  action_item :summary, only: %i[show edit] do
    link_to 'Summary', summary_family_path(family)
  end

  action_item :nametag, only: %i[show edit] do
    link_to 'Nametags (PDF)', nametag_family_path(family), target: '_blank' if family.checked_in?
  end

  action_item :new_payment, only: :summary do
    link_to 'New Payment', new_family_payment_path(params[:id])
  end

  action_item :link_back, only: :summary do
    link_to 'Back to Family', action: :show
  end

  member_action :summary do
    family = Family.find(params[:id])
    finances = FamilyFinances::Report.call(family: family)

    render :summary, locals: { family: family, finances: finances }
  end

  collection_action :balance_due do
    csv_string = CSV.generate do |csv|
      csv << %w(FamilyID Last First Email Phone Amount Checked-in)
      Family.includes(:chargeable_staff_number).order(:last_name).each do |f|
        next if f.chargeable_staff_number?

        finances = FamilyFinances::Report.call(family: f)
        balance = finances.subtotal - finances.paid
        next if balance == 0

        csv << [f.id, f.last_name, f.first_name, f.email, f.phone, balance, f.checked_in?]
      end
    end

    send_data(csv_string, filename: "Balance Due - #{Date.today.to_s(:db)}.csv")
  end

  collection_action :finance_track_dump do
    csv_string = CSV.generate do |csv|
      csv << %w(FamilyID Last First StaffId Checked-in StaffConf Xtrack NST NSO MTL MTLSpouse MPD Legacy CW)
      Family.includes(:chargeable_staff_number, {attendees: :conferences}).order(:last_name).each do |f|
        row = [f.id, f.last_name, f.first_name, "_#{f.staff_number}", f.checked_in?]

        row << StaffConference::SumFamilyCost.call(family: f).total

        xtrack = nst = nso = mtl = mtl_spouse = mpd = legacy = cw = 0

        f.attendees.each do |attendee|
          attendee.conferences.reject(&:staff_conference?).each do |conference|
            next if conference.price.zero?
            sum = Conference::SumAttendeeCost.call(attendee: attendee)
            amount = ApplyCostAdjustments.call(charges: sum.charges,
                                      cost_adjustments: sum.cost_adjustments).total
            case
              when conference.name == 'XTrack Participant'
                xtrack += amount
              when conference.name == 'New Staff Training'
                nst += amount
              when conference.name == 'New Staff Orientation'
                nso += amount
              when conference.name == 'Missional Team Leader Training Participant'
                mtl += amount
              when conference.name == 'Missional Team Leader Spouse'
                mtl_spouse += amount
              when conference.name =~ /MPD.*/
                mpd += amount
              when conference.name == 'Legacy Track (Staff 60 years of age and older)'
                legacy += amount
              when conference.name =~ /Connection Weekend Attendee.*/
                cw += amount
            end
          end
        end

        row += [xtrack, nst, nso, mtl, mtl_spouse, mpd, legacy, cw]

        csv << row
      end
    end

    send_data(csv_string, filename: "Finance Track Dump - #{Date.today.to_s(:db)}.csv")
  end

  collection_action :finance_full_dump do
    csv_string = CSV.generate do |csv|
      csv << ['FamilyID', 'Last','First','Staff Id','Checked-In','Adult Dorm','Adult Dorm Adj','Apt Rent','Apt Rent Adj',
              'Child Dorm','Child Dorm Adj','Childcare','Childcare Adj','Hot Lunch','Hot Lunch Adj','JrSr','JrSr Adj',
              'Facility Use Fee','Facility Use Fee Adj','Class Tuition','Class Tuition Adj','Track Tuition',
              'Track Tuition Adj','USSC Tuition','USSC Tuition Adj','Rec Pass',
              'Rec Pass Adj','Pre Paid', 'Ministry Acct', 'Cash/Check', 'Credit Card', 'Charge Staff Acct',
              'Business Unit', 'Operating Unit', 'Department', 'Project', 'Reference'
      ]
      Family.includes(:primary_person, :payments, {attendees: [:courses, :conferences, :cost_adjustments]},
                      {children: :cost_adjustments})
          .order(:last_name).each do |family|

        finances = FamilyFinances::Report.call(family: family)

        totals = Stay::SumFamilyAttendeesDormitoryCost.call(family: family)
        adult_dorm = totals.total
        adult_dorm_adj = totals.total_adjustments

        totals = Stay::SumFamilyAttendeesApartmentCost.call(family: family)
        adult_apt = totals.total
        adult_apt_adj = totals.total_adjustments

        totals = Stay::SumFamilyChildrenCost.call(family: family)
        child_dorm = totals.total
        child_dorm_adj = totals.total_adjustments

        totals = Childcare::SumFamilyCost.call(family: family)
        childcare = totals.total
        childcare_adj = totals.total_adjustments

        totals = HotLunch::SumFamilyCost.call(family: family)
        hot_lunch = totals.total
        hot_lunch_adj = totals.total_adjustments

        totals = JuniorSenior::SumFamilyCost.call(family: family)
        jrsr = totals.total
        jrsr_adj = totals.total_adjustments

        totals = FacilityUseFee::SumFamilyCost.call(family: family)
        fuf = totals.total
        fuf_adj = totals.total_adjustments

        totals = Course::SumFamilyCost.call(family: family)
        class_tuition = totals.total
        class_tuition_adj = totals.total_adjustments

        totals = Conference::SumFamilyCost.call(family: family)
        track_tuition = totals.total
        track_tuition_adj = totals.total_adjustments

        totals = StaffConference::SumFamilyCost.call(family: family)
        ussc_tuition = totals.total
        ussc_tuition_adj = totals.total_adjustments

        totals = RecPass::SumFamilyCost.call(family: family)
        rec = totals.total
        rec_adj = totals.total_adjustments

        pre_paid = family.payments.to_a.select(&:pre_paid?).inject(0) {|sum, p| sum + p.price}
        ministry_payments = family.payments.to_a.select {|p| p.business_account? || p.staff_code?}
        ministry_payment_amount = ministry_payments.inject(0) {|sum, p| sum + p.price}
        cash_check = family.payments.to_a.select(&:cash_check?).inject(0) {|sum, p| sum + p.price}
        credit_card = family.payments.to_a.select(&:credit_card?).inject(0) {|sum, p| sum + p.price}
        staff_code = finances.unpaid

        csv << [
          family.id, family.last_name, family.first_name, "_#{family.staff_number}", family.checked_in?,
          adult_dorm, adult_dorm_adj, adult_apt, adult_apt_adj, child_dorm, child_dorm_adj, childcare, childcare_adj,
          hot_lunch, hot_lunch_adj, jrsr, jrsr_adj, fuf, fuf_adj, class_tuition, class_tuition_adj,
          track_tuition, track_tuition_adj, ussc_tuition, ussc_tuition_adj, rec, rec_adj, pre_paid, ministry_payment_amount,
          cash_check, credit_card, staff_code, ministry_payments.collect(&:business_unit).join(', '),
          ministry_payments.collect(&:operating_unit).join(', '), ministry_payments.collect(&:department_code).join(', '),
          ministry_payments.collect(&:project_code).join(', '), ministry_payments.collect(&:reference).join(', ')
        ]
      end
    end

    send_data(csv_string, filename: "Finance Full Dump - #{Date.today.to_s(:db)}.csv")
  end

  member_action :checkin, method: :post do
    return head :forbidden unless authorized?(:checkin, Family)

    @family = Family.find(params[:id])
    @finances = FamilyFinances::Report.call(family: @family)

    if @finances.remaining_balance.zero?
      @family.check_in!
      respond_to do |format|
        format.html do
          redirect_to summary_family_path(@family.id), notice: 'Checked-in!'
        end
        format.js
      end
    else
      redirect_to summary_family_path(@family.id),
                  alert: "The family's balance must be zero to check-in."
    end
  end

  collection_action :nametags do
    applicable = collection.select(&:checked_in?)
    roster = AggregatePdfService.call(Family::Nametag, applicable,
                                      key: :family, author: current_user)
    send_data(roster.render, type: 'application/pdf', disposition: :inline)
  end

  member_action :nametag do
    roster = Family::Nametag.call(family: Family.find(params[:id]),
                                  author: current_user)

    send_data(roster.render, type: 'application/pdf', disposition: :inline)
  end

  sidebar 'Nametags', only: :index do
    link_to 'Checked-in Families (PDF)', params.merge(action: :nametags)
  end

  controller do
    def update
      update! do |format|
        format.html do
          if request.referer.include?('housing')
            redirect_to housing_path(family_id: @family.id)
          else
            redirect_to families_path
          end
        end
      end
    end
  end
end
