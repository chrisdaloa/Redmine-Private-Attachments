module RedminePrivateAttachments
  module JournalPatch
    def visible_details(user = User.current)
      super.reject do |detail|
        next false unless detail.property == 'attachment'

        attachment = Attachment.find_by(id: detail.prop_key)
        next false unless attachment&.private?

        project = attachment.container&.respond_to?(:project) ? attachment.container.project : nil
        !project || !user.allowed_to?(:view_private_notes, project)
      end
    end
  end
end

Journal.prepend(RedminePrivateAttachments::JournalPatch)
