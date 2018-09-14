class Childcare::Signin::Base < PdfService
  attr_accessor :childcare
  attr_accessor :week

  def call
    font 'Comic Sans'

    header
    children_table

    printed_at_footer
    page_numbers_footer
  end

  protected

  def children
    @children ||= begin
      children =
        childcare.children.order(:last_name, :first_name).select do |child|
          child.childcare_weeks.include?(week)
        end

      children.any? ? children : [Child.new]
    end
  end

  def name_cell(child)
    "#{child.last_name}\n#{nbsp + nbsp + nbsp}#{child.first_name}"
  end

  def header
    text header_text, align: :center, style: :bold, size: title_font_size
    header_table
    move_down 0.25.in
  end

  def header_text
    childcare.name
  end

  private

  def header_table
    font_size header_font_size do
      table header_table_data, position: :center, width: bounds.width do |t|
        t.cells.borders = []
        t.column(0).align = :right
        t.column(0).width = 1.5.in
        t.column(1).font_style = :bold

        style_date_input(t.row(0).columns(-2), t.row(0).columns(-1))
      end
    end
  end

  def style_date_input(label_col, input_col)
    label_col.align = :right
    label_col.valign = :bottom
    input_col.width = 3.in
    input_col.borders = [:bottom]
  end

  def header_table_data
    [
      ['Location:',   childcare.location, 'Date:', ''],
      ['Room #:',     { content: childcare.room, colspan: 3 }],
      ['Counselors:', { content: childcare.teachers, colspan: 3 }]
    ]
  end

  def children_table
    data = [columns] + table_rows
    move_down 0.5.in

    table data, header: true, position: :center, width: bounds.width do |t|
      t.cells.border_width = 0.25
      t.cells.font_style = :bold

      style_children_header(t)
      style_row_span_cells(t)
      style_input_cells(t)
    end
  end

  def style_children_header(t)
    t.row(0).borders = [:bottom]
    t.row(0).border_width = 2
  end

  def style_row_span_cells(t)
    name_size = font_size * 1.25
    name_column = t.row(1..-1).columns(row_span_columns)
    bottom_cells = t.cells.filter { |c| c.row.modulo(3).zero? }

    name_column.valign = :center
    name_column.borders = [:bottom]
    name_column.border_width = 2
    name_column.size = name_size

    bottom_cells.border_bottom_width = 2
  end

  def style_input_cells(t)
    input_size = font_size * 0.6
    input_columns = t.row(1..-1).columns(1..2)

    input_columns.font_style = :normal
    input_columns.size = input_size
    input_columns.height = input_size * 4
    input_columns.width = 2.in
    input_columns.padding = 2
  end
end
