class Family::Nametag < PdfService
  INVALID_BARCODE_REGEX = %r{[^\w$%*+-./ ]}
  INVALID_BARCODE_REPLACEMENT = '_'.freeze

  CONTACT_LINES = [
    'Cru17 Emergency/Security: (407) 232-1084',
    'Durrell Information Services: (970) 491-4345',
    'Kids Care: Johnson Elementary: (970) 488-4749',
    'Kids Camp: Webber Middle: (970) 488-4748',
    'Conference Information: go to the Cru17 app',
    'and www.cru.org/cru17',
    'All Cru17 morning sessions start at 9:30am'
  ].freeze

  FONTS = {
    first_name: 'Gotham',
    last_name: 'Gotham',
    location: 'Gotham',
    contact: 'Arial Narrow',
    barcode_label: 'Arial',
    barcode: 'Barcode'
  }.freeze

  STYLES = {
    first_name: { style: :normal, color: '000000', size: 38 }.freeze,
    last_name: { style: :normal, color: 'fbad3a', size: 38 }.freeze,
    location: { style: :bold, color: '8c8c8c', size: 14 }.freeze,
    contact: { color: '000000', size: 12 }.freeze,
    barcode: { color: '000000', size: 24 }.freeze,
    barcode_label: { color: '000000', size: 10 }.freeze
  }.freeze

  attr_accessor :family

  document_options page_size: [8.5.in, 14.in],
                   top_margin:    1.in,
                   right_margin:  0.25.in,
                   bottom_margin: 1.in,
                   left_margin:   0.25.in

  def call
    font 'Gotham' do
      applicable_members.each_slice(2).each_with_index do |per_page, page|
        start_new_page unless page.zero?
        per_page.each(&method(:render_nametag))
      end
    end
  end

  def metadata
    super.tap do |meta|
      meta[:Title] = format('Nametags for %s', family)
    end
  end

  private

  def applicable_members
    @applicable_members ||= family.attendees + senior_children
  end

  def senior_children
    family.children.where(grade_level: Child.senior_grade_levels)
  end

  def render_nametag(attendee)
    top = cursor

    bounding_box [0, top], width: 4.in, height: 6.in do
      render_nametag_front(attendee)
    end

    bounding_box [4.in, top], width: 4.in, height: 6.in do
      render_nametag_back(attendee)
    end
  end

  def render_nametag_front(attendee)
    top = bounds.top - 3.in
    margin = 0.25.in
    width = bounds.width - margin * 2

    render_first_name(attendee, at: [margin, top],
                                width: width, height: 0.5.in)
    render_last_name(attendee, at: [margin, top - 0.5.in], width: width)

    render_location(at: [margin, top - 1.3.in], width: width)
  end

  def single_line(str, style_name, opts = {})
    valign = opts[:height].present? ? :bottom : :top
    opts = STYLES[style_name].merge(opts).merge(
      valign: valign, single_line: true, overflow: :shrink_to_fit
    )

    # Note: text_box does not use #color, so we have to manually set the fill
    old_fill = fill_color
    fill_color STYLES[style_name].fetch(:color, old_fill)

    font(FONTS[style_name]) { text_box str, opts }

    fill_color old_fill
  end

  def render_first_name(attendee, opts = {})
    single_line(attendee.first_name_tag, :first_name, opts)
  end

  def render_last_name(attendee, opts = {})
    single_line(attendee.last_name_tag, :last_name, opts)
  end

  def render_location(opts = {})
    location = [family.city, family.state].select(&:present?).join(', ').upcase
    single_line(location, :location, opts)
  end

  def render_nametag_back(attendee)
    top = bounds.top - 2.in
    width = bounds.width

    bounding_box [0, top], width: width do
      render_contact_lines
    end

    return unless attendee.is_a?(Attendee)

    bounding_box [0, top - 2.5.in], width: width do
      render_name_barcode(attendee)
    end

    bounding_box [0, top - 3.3.in], width: width do
      render_staff_number_barcode
    end
  end

  def render_contact_lines
    CONTACT_LINES.each do |line|
      font(FONTS[:contact], STYLES[:contact]) { text line, align: :center }
    end
  end

  def render_name_barcode(attendee)
    single_line(attendee.full_name.upcase, :barcode_label, align: :center)
    single_line(barcode(attendee.full_name), :barcode,
                align: :center, at: [0, -STYLES[:barcode_label][:size]])
  end

  def render_staff_number_barcode
    font FONTS[:barcode_label], STYLES[:barcode_label] do
      text family.staff_number.upcase, align: :center
    end
    font FONTS[:barcode], STYLES[:barcode] do
      text barcode(family.staff_number), align: :center
    end
  end

  def barcode(str)
    format('*%s*', str.to_s.upcase.gsub(INVALID_BARCODE_REGEX,
                                        INVALID_BARCODE_REPLACEMENT))
  end
end
