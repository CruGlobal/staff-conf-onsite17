require 'prawn/measurement_extensions'

class PdfService < ApplicationService
  include Prawn::View

  TITLE_SIZE_FACTOR = 2.2
  HEADER_SIZE_FACTOR = 1.25

  # @see +app/assets/fonts/+
  # @see https://github.com/prawnpdf/prawn/tree/master/lib/prawn/font/
  EXTRA_FONTS = {
    'Arial' => {
      normal: 'Arial.ttf',
      bold: 'Arial-Bold.ttf',
      italic: 'Arial-Italic.ttf',
      bold_italic: 'Arial-BoldItalic.ttf'
    }.freeze,
    'Arial Narrow' => {
      normal: 'ArialNarrow.ttf',
      bold: 'ArialNarrow-Bold.ttf',
      italic: 'ArialNarrow-Italic.ttf',
      bold_italic: 'ArialNarrow-BoldItalic.ttf'
    }.freeze,
    'Barcode' => {
      normal: 'free3of9.ttf'
    }.freeze,
    'Comic Sans' => {
      normal: 'ComicSans.ttf',
      bold:   'ComicSans-Bold.ttf'
    }.freeze,
    'DejaVu Sans' => {
      normal:      'DejaVuSans.ttf',
      bold:        'DejaVuSans-Bold.ttf',
      italic:      'DejaVuSans-Oblique.ttf',
      bold_italic: 'DejaVuSans-BoldOblique.ttf'
    }.freeze,
    'FontAwesome' => {
      normal: 'FontAwesome.ttf',
      bold: 'FontAwesome.ttf'
    }.freeze,
    'Gotham' => {
      light: 'Gotham-Light.ttf',
      normal: 'Gotham-Book.ttf',
      bold: 'Gotham-Bold.ttf'
    }.freeze
  }.freeze

  def_delegator :document, :render, :render_pdf

  attr_accessor :author
  attr_writer :document
  attr_accessor :aggregrate_pdf

  after_initialize :update_font_families

  class << self
    def page_layout(layout = nil)
      @page_layout = layout if layout.present?
      @page_layout || :portrait
    end

    def document_options(options = nil)
      @document_options = options if options.present?
      @document_options || {}
    end
  end

  def render
    render_pdf
  end

  def document
    @document ||=
      Prawn::Document.new({
        info: metadata,
        page_layout: page_layout
      }.merge(document_options))
  end

  def metadata
    {
      Author: author&.full_name || author,
      CreationDate: creation_date,
      Producer: ActiveAdmin.application.site_title
    }
  end

  def creation_date
    @creation_date ||= Time.zone.now
  end

  protected

  def page_layout
    self.class.page_layout
  end

  def document_options
    self.class.document_options
  end

  def shy
    Prawn::Text::SHY
  end

  def nbsp
    Prawn::Text::NBSP
  end

  def zwsp
    Prawn::Text::ZWSP
  end

  # A bounding-box may be required if there is repeating content above the
  # table, so it doesn't overlap the table if the table spans more than one
  # page.
  #
  # @see #repeat
  def wrap_table(&blk)
    bounding_box([bounds.left, cursor], width: bounds.width, &blk)
  end

  def title_font_size
    font_size * TITLE_SIZE_FACTOR
  end

  def header_font_size
    font_size * HEADER_SIZE_FACTOR
  end

  def printed_at_footer(padding: 3.mm)
    @printed_at_footer = padding
    return if aggregrate_pdf

    m = page.margins
    left = m[:left] + padding
    bottom = m[:bottom] - padding
    width = bounds.width - padding * 2

    repeat(:all) do
      canvas do
        text_box format('Printed: %s ', creation_date),
                 align: :right, at: [left, bottom], width: width
      end
    end
  end

  def printed_at_footer?
    @printed_at_footer
  end

  def page_numbers_footer(padding: 3.mm)
    @page_numbers_footer = padding
    return if aggregrate_pdf

    number_pages 'page <page> of <total>', at: [padding, -padding]
  end

  def page_numbers_footer?
    @page_numbers_footer
  end

  private

  def update_font_families
    font_families.update(Hash[
      EXTRA_FONTS.map do |family, fonts|
        styles =
          Hash[fonts.map { |style, filename| [style, font_path(filename)] }]
        [family, styles]
      end
    ])
  end

  def font_path(*args)
    Rails.root.join('app', 'assets', 'fonts', *args)
  end
end
