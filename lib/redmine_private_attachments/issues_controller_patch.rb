module RedminePrivateAttachments
  module IssuesControllerPatch
    def self.included(base)
      base.class_eval do
        after_action :sync_attachment_privacy, only: [:create, :update]
      end
    end

    private

    def sync_attachment_privacy
      return unless @issue&.persisted?
      return unless params.dig(:issue, :private_notes).to_s == '1'

      # params[:attachments] is a hash { token => { filename, description } }
      # where token == disk_filename, set by Redmine's AttachmentsController#upload.
      tokens = params[:attachments].presence&.keys || []
      return if tokens.empty?

      Attachment
        .where(disk_filename: tokens)
        .where(container_type: 'Issue', container_id: @issue.id)
        .update_all(private: true)
    end
  end
end

IssuesController.include(RedminePrivateAttachments::IssuesControllerPatch)
