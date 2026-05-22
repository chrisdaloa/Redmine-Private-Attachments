module RedminePrivateAttachments
  module IssuesControllerPatch
    def self.included(base)
      base.class_eval do
        before_action :capture_private_attachment_ids, only: [:update]
        after_action  :sync_attachment_privacy,        only: [:create, :update]
      end
    end

    private

    # Snapshot private attachment IDs before the update so we can track deletions.
    def capture_private_attachment_ids
      return unless params[:id]
      @pre_update_private_ids = Attachment
        .where(container_type: 'Issue', container_id: params[:id], private: true)
        .pluck(:id)
        .map(&:to_s)
    end

    def sync_attachment_privacy
      return unless @issue&.persisted?

      new_private_ids = []

      if params.dig(:issue, :private_notes).to_s == '1'
        tokens = params[:attachments].presence&.values || []
        new_private_ids = tokens.filter_map { |a| (a[:token] || a['token']).to_s.split('.').first.to_i.nonzero? }

        if new_private_ids.any?
          Attachment
            .where(id: new_private_ids)
            .where(container_type: 'Issue', container_id: @issue.id)
            .update_all(private: true)
        end
      end

      # Union of newly private IDs and pre-existing private IDs (covers deletions too).
      all_private_ids = (new_private_ids.map(&:to_s) + Array(@pre_update_private_ids)).uniq
      return if all_private_ids.empty?

      # Mark every journal that references these attachments as private so Redmine
      # hides the "File aggiunto / eliminato" entries from unauthorized users.
      journal_ids = JournalDetail
        .joins(:journal)
        .where(
          journals: { journalized_type: 'Issue', journalized_id: @issue.id, private_notes: false },
          property: 'attachment',
          prop_key: all_private_ids
        )
        .pluck(:journal_id)
        .uniq

      Journal.where(id: journal_ids).update_all(private_notes: true) if journal_ids.any?
    end
  end
end

IssuesController.include(RedminePrivateAttachments::IssuesControllerPatch)
