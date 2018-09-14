class Childcare::Signin::CarLine < Childcare::Signin::Portrait
  attr_accessor :childcares
  attr_accessor :week

  i18n_scope %i[childcare car_line]

  def page_title
    t('document.title')
  end

  def header_text
    t('header.title')
  end

  def children
    @children ||= begin
      children = Child.where(childcare: childcares, parent_pickup: true)
      children =
        children.order(:last_name, :first_name).select do |child|
          child.childcare_weeks.include?(week)
        end

      children.any? ? children : [Child.new]
    end
  end

  def header_table_data
    [['', t('header.date'), '']]
  end
end
