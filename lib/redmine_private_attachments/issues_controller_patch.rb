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

      # params[:attachments] is { "1" => { token: "#{id}.#{digest}", filename: ... }, ... }
      # The token prefix is the attachment id, confirmed by Redmine's token format.
      tokens = params[:attachments].presence&.values || []
      attachment_ids = tokens.filter_map { |a| (a[:token] || a['token']).to_s.split('.').first.to_i.nonzero? }
      return if attachment_ids.empty?

      Attachment
        .where(id: attachment_ids)
        .where(container_type: 'Issue', container_id: @issue.id)
        .update_all(private: true)
    end
  end
end

IssuesController.include(RedminePrivateAttachments::IssuesControllerPatch)
