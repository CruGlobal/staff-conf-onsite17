module PaperTrailHelper
  def version_label(version)
    if version.item
      link_to version.item.audit_name, version.item
    else
      "#{version.item_type} ##{version.item_id}"
    end
  end

  # @return [String] a link to the user who edited the given version
  def editor_link(version)
    if version.whodunnit.present?
      editor = User.find(version.whodunnit)
      link_to editor.email, editor
    else
      'Unknown'
    end
  end

  # @return [Hash] a hash of the record attributes in the previous
  #   version. It will be empty if this is the first created version
  def previous_version_hash(version)
    # rubocop:disable Security/YAMLLoad
    version.object ? YAML.load(version.object) : {}
  end
end
