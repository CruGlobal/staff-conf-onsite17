module CostCodeHelper
  include TextHelper

  # @return [Array<[label, id]>] the {CostCode} +<select>+ options acceptable
  #   for +options_for_select+
  def cost_code_select
    CostCode.all.map { |c| [c.to_s, c.id] }
  end

  # @return [String] a description of the given {CostCode}
  def cost_code_label(c)
    desc = html_summary(c.description)
    desc = strip_tags(desc)

    "#{c.name}: #{desc}"
  end
end
