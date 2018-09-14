class Childcare::Signin::Portrait < Childcare::Signin::Base
  page_layout :portrait

  def metadata
    super.tap do |meta|
      meta[:Title] = page_title
    end
  end

  protected

  def page_title
    format('Sign-in (portrait): %s', childcare.name)
  end

  # @return [Array<String>] the column names
  def columns
    ['Last Name, First Name', 'In:', 'Out:']
  end

  # @return [Array<Integer>] the column indexes which span multiple rows
  def row_span_columns
    [0]
  end

  # @return [Array<Array>] the data represeting the sign-in table
  def table_rows
    children.flat_map do |child|
      [
        [{ content: name_cell(child), rowspan: 3 }, 'Time', 'Time'],
        %w[Signature Signature],
        ['Print Name', 'Print Name']
      ]
    end
  end
end
