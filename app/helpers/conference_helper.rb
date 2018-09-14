module ConferenceHelper
  # @return [Array<[label, id]>] the {Conference} +<select>+ options acceptable
  #   for +options_for_select+
  def conferences_select
    Conference.all.order(:position).map { |c| [c.name, c.id] }
  end
end
