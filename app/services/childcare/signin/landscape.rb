class Childcare::Signin::Landscape < Childcare::Signin::Base
  page_layout :landscape

  def metadata
    super.tap do |meta|
      meta[:Title] = format('Sign-in (landscape): %s', childcare.name)
    end
  end

  protected

  # @return [Array<String>] the column names
  def columns
    ['Last Name, First Name', 'In:', 'Out:', 'Special Pickup Instructions']
  end

  # @return [Array<Integer>] the column indexes which span multiple rows
  def row_span_columns
    [0, 3]
  end

  # @return [Array<Array>] the data represeting the sign-in table
  def table_rows
    children.flat_map do |child|
      [
        [
          { content: name_cell(child), rowspan: 3 },
          'Time', 'Time',
          { content: '', rowspan: 3 }
        ],
        %w[Signature Signature],
        ['Print Name', 'Print Name']
      ]
    end
  end
end
