module RedminePrivateAttachments
  module AttachmentsControllerPatch
    def self.included(base)
      base.class_eval do
        before_action :check_attachment_privacy, only: [:show, :download, :thumbnail]
      end
    end

    private

    def check_attachment_privacy
      return unless @attachment&.private?

      container = @attachment.container
      project = container.respond_to?(:project) ? container.project : nil

      # Deny access when project is nil (orphaned attachment) or user lacks permission.
      unless project && User.current.allowed_to?(:view_private_notes, project)
        render_403
      end
    end
  end
end

AttachmentsController.include(RedminePrivateAttachments::AttachmentsControllerPatch)
