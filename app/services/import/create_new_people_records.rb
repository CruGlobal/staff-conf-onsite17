class Import::CreateNewPeopleRecords < UploadService
  include ActionView::Helpers::OutputSafetyHelper
  include Rails.application.routes.url_helpers

  # Associates the row number a given record was created on, so in the event
  # of an error we can report to the end user which row of the spreadsheet
  # caused the error.
  RowRecord = Struct.new(:record, :row)

  Error = Class.new(StandardError)
  PersonExistsError = Class.new(Error)

  job_stage 'Persist New Database Records'
  i18n_scope 'import'

  # +Array<Import::Person>+
  attr_accessor :imports

  def call
    ApplicationRecord.transaction do
      people = create_people
      persist_records!(families.values, people)
    end
  rescue PersonExistsError
    fail_job!(message: existing_people_message)
  rescue Import::UpdatePersonFromImport::MinistryMissing
    raise
  rescue StandardError => e
    fail_job!(message: e.message)
  end

  private

  def families
    @families ||= {}
  end

  def create_people
    count = imports.size.to_f

    imports.each_with_index.map do |import, index|
      update_stage(index, count, stage: 1)
      create_from_import(import, index)
    end
  end

  def existing_people_message
    safe_join [t('error.existing_people'), existing_people_list]
  end

  def existing_people
    imports.map do |import|
      family = existing_family(import)
      next if family.nil?
      family.people.find do |p|
        p.birthdate == import.birthdate && p.first_name == import.first_name
      end
    end.compact
  end

  def existing_family(import)
    tag = import.family_tag

    if families.key?(tag)
      families[tag].record
    else
      primary_person =
        imports.find do |p|
          p.family_tag == tag && p.primary_family_member?
        end
      (primary_person || import).family_record
    end
  end

  def create_from_import(import, index)
    row = index + 2
    create_person(import, row).tap { |p| set_attributes(p.record, import) }
  rescue PersonExistsError
    raise
  rescue Import::UpdatePersonFromImport::MinistryMissing
    raise
  rescue StandardError => e
    raise Error, format('Row #%d: %s', row, e)
  end

  def create_person(import, row)
    family = find_or_create_family(import, row)

    raise PersonExistsError if find_existing_person(import, row).present?

    person = import.record_class.new.tap { |p| p.family = family.record }
    RowRecord.new(person, row)
  end

  def find_existing_person(import, row)
    family = find_or_create_family(import, row)

    family.record.people.find do |p|
      p.birthdate == import.birthdate && p.first_name == import.first_name
    end
  end

  def find_or_create_family(import, row)
    tag = import.family_tag
    return families[tag] if families.key?(tag)

    primary_person =
      imports.find { |p| p.family_tag == tag && p.primary_family_member? }
    primary_person ||= import # fallback if primary is missing (unusual)

    family = primary_person.family_record || create_family(primary_person)
    families[primary_person.family_tag] = RowRecord.new(family, row)
  end

  def create_family(primary)
    Family.create!(last_name: primary.last_name, import_tag:
                   primary.family_tag).tap do |family|
      update_family(family, primary)
    end
  end

  def set_attributes(person, import)
    update_family(person.family, import) if import.primary_family_member?
    update_person(person, import)
  end

  def update_family(family, import)
    Import::UpdateFamilyFromImport.call(family: family, import: import)
  end

  def update_person(person, import)
    Import::UpdatePersonFromImport.call(person: person, import: import,
                                        ministries: ministries)
  end

  def ministries
    @ministries ||= Ministry.all
  end

  def persist_records!(families, people)
    families.each(&method(:save_record!))

    count = people.size.to_f
    people.each_with_index do |person, index|
      update_stage(index, count, stage: 2)
      save_record!(person)
    end
  end

  def save_record!(row_record)
    record = row_record.record
    record.save!
  rescue ActiveRecord::ActiveRecordError => e
    raise Error, format('Row #%d: Could not persist %s, %p. %s',
                        row_record.row, record.class.name, record.audit_name,
                        e.message)
  end

  def existing_people_list
    Arbre::Context.new(receiver: self) do
      ul do
        receiver.send(:existing_people).each do |person|
          li do
            a(person.full_name, href: receiver.send(:person_path, person))
          end
        end
      end
    end
  end

  def person_path(person)
    case person
    when Attendee then attendee_path(person)
    when Child then child_path(person)
    end
  end

  def update_stage(index, count, stage:)
    return unless index.modulo(100).zero?
    case stage
    when 1 then update_percentage(index / count * 0.5)
    when 2 then update_percentage(index / count * 0.5 + 0.5)
    end
  end
end
