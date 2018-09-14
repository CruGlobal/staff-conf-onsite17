require 'phone'
require 'truncate_html'

module TextHelper
  # This method truncates the given string, ensuring any open tags are closed
  # and no tags are cut in half
  # @return [string] a truncated version of the given HTML string
  def html_summary(html)
    html_string = TruncateHtml::HtmlString.new(html || '')
    html_full(TruncateHtml::HtmlTruncator.new(html_string).truncate)
  end

  # @return [string] an HTML-safe version of the given string
  def html_full(html)
    # rubocop:disable Rails/OutputSafety
    html.html_safe if html.present?
  end

  def format_phone(number)
    if (phone = Phoner::Phone.parse(number))
      phone.format('+%c (%a) %f-%l')
    else
      ''
    end
  rescue StandardError
    number
  end

  def strip_tags(html)
    @sanitizer ||= Rails::Html::Sanitizer.full_sanitizer.new
    @sanitizer.sanitize(html, encode_special_chars: false)
  end
end
