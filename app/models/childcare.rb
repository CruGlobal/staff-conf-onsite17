class Childcare < ApplicationRecord
  acts_as_list
  has_paper_trail

  belongs_to :family
  has_many :children, dependent: :nullify

  # The list of individual weeks that children may attend.
  #
  # @note {Child#childcare_weeks=} accepts a list of indexes into this list,
  #   not the strings themselves.
  CHILDCARE_WEEKS = ['Week 1', 'Week 2', 'Week 3', 'Week 4',
                     'Staff Conference'].freeze

  def audit_name
    "#{super}: #{name}"
  end
end
