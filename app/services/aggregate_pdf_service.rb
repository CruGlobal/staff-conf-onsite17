# Runs a PDF creation service for each record in a given collection, returning
# a single PDF, joining them all.
class AggregatePdfService < PdfService
  DEFAULT_KEY = :record

  # The service class to render for each record in the collection
  attr_accessor :service

  # The collection of records to render
  attr_accessor :collection

  # The options to build the {#service} instance with
  attr_accessor :options

  # The name of the {#service} constructor argument to pass the records, if not
  # +:record+
  attr_accessor :key

  def_delegators :service, :page_layout, :document_options

  def initialize(service, collection, opts = {})
    self.service = service
    self.collection = collection
    self.key = opts.delete(:key) || DEFAULT_KEY
    self.options = opts

    super({})
  end

  def call
    if collection.any?
      render_collection
    else
      text 'No records found.'
    end

    print_aggregate_footers
  end

  private

  def render_collection
    collection.each_with_index do |record, index|
      start_new_page unless index.zero?
      doc = service.call(service_options(record))

      @print_page_numbers_footer = doc.page_numbers_footer?
      @print_printed_at_footer = doc.printed_at_footer?
    end
  end

  def service_options(record)
    options.merge(key => record, document: document, aggregrate_pdf: true)
  end

  def print_aggregate_footers
    if @print_printed_at_footer
      printed_at_footer(padding: @print_printed_at_footer)
    end

    if @print_page_numbers_footer
      page_numbers_footer(padding: @print_page_numbers_footer)
    end
  end
end
