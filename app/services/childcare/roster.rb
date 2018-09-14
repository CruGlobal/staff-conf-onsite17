class Childcare::Roster < PdfService
  COLUMNS = ['', 'Last Name', 'First Name', 'Gender', 'Hot Lunch?',
             'PM Car Line'].freeze

  # @see http://fontawesome.io/icon/square-o
  ICON_NO  = "\uf096".freeze

  # @see http://fontawesome.io/icon/check-square-o
  ICON_YES = "\uf046".freeze

  attr_accessor :childcare
  attr_accessor :week

  def call
    font 'Comic Sans'

    header
    children_table

    printed_at_footer
    page_numbers_footer
  end

  def metadata
    super.tap do |meta|
      meta[:Title] = format('Roster: %s', childcare.name)
    end
  end

  private

  def header
    text childcare.name, align: :center, style: :bold, size: title_font_size
    header_table
    move_down 0.25.in
  end

  def header_table
    data = [
      ['Location:', childcare.location],
      ['Room #:', childcare.room],
      ['Counselors:', childcare.teachers],
      ['When:', Childcare::CHILDCARE_WEEKS[week]]
    ]

    font_size header_font_size do
      table data, position: :center, cell_style: { border_width: 0 } do
        column(0).align = :right
        column(0).width = 2.in
        column(1).font_style = :bold
      end
    end
  end

  def children_table
    data = [COLUMNS] + table_rows

    move_down 0.5.in

    table data, header: true, position: :center, width: bounds.width do
      cells.borders = []

      row(0).font_style = :bold
      row(0).borders = [:bottom]
      row(0).border_width = 2

      column(2..-1).align = :center
      column(3..-1).rows(1..-1).font = 'FontAwesome'
    end
  end

  def table_rows
    children.each_with_index.map do |child, i|
      [
        i + 1,
        child.last_name,
        child.first_name,
        child.gender&.upcase,
        hot_lunch?(child) ? ICON_YES : ICON_NO,
        child.parent_pickup? ? ICON_YES : ICON_NO
      ]
    end
  end

  def children
    childcare.children.order(:last_name, :first_name).select do |child|
      child.childcare_weeks.include?(week)
    end
  end

  def hot_lunch?(child)
    child.hot_lunch_weeks.include?(week)
  end
end
