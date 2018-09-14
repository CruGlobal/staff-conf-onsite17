class Family < ApplicationRecord
  include PersonHelper

  has_paper_trail

  has_many :people, dependent: :destroy
  has_many :attendees, dependent: :destroy
  has_many :children, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_one :housing_preference, autosave: true, dependent: :destroy,
                               inverse_of: :family
  has_one :chargeable_staff_number, primary_key: :staff_number,
                                    foreign_key: :staff_number
  belongs_to :primary_person, class_name: 'Attendee',
                              foreign_key: :primary_person_id

  accepts_nested_attributes_for :housing_preference
  accepts_nested_attributes_for :people

  validates :last_name, presence: true
  validates_associated :housing_preference

  before_validation :remove_blank_housing_preference

  # @see PersonHelper.family_label
  def to_s
    family_label(self)
  end

  def first_name
    (primary_person || attendees.first).try(:first_name)
  end

  def email
    (primary_person || attendees.first).try(:email)
  end

  def phone
    (primary_person || attendees.first).try(:phone)
  end

  def audit_name
    "#{super}: #{family_label(self)}"
  end

  def chargeable_staff_number?
    chargeable_staff_number.present?
  end

  def cost_adjustments
    people.flat_map(&:cost_adjustments)
  end

  def check_in!
    self.class.transaction { attendees.each(&:check_in!) }
    if anyone_has_email?
      FamilyMailer.summary(self).deliver_now
      FamilyMailer.media_release(self).deliver_now
    end
  end

  def checked_in?
    attendees.any? && attendees.all?(&:checked_in?)
  end

  def everyone_has_birthdates?
    people.all? { |p| p.birthdate.present? }
  end

  def anyone_has_email?
    attendees.any? { |p| p.email.present? }
  end

  private

  def remove_blank_housing_preference
    self.housing_preference = nil if housing_preference&.housing_type&.blank?
  end
end
