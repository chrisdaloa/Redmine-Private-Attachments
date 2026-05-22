require 'redmine'

Redmine::Plugin.register :redmine_private_attachments do
  name        'Redmine Private Attachments'
  author      'Christian Borrello'
  description 'Hides attachments on private notes from users without view_private_notes permission.'
  version     '0.0.1'
  requires_redmine version_or_higher: '5.0.0'
end

Rails.configuration.to_prepare do
  load File.join(__dir__, 'lib/redmine_private_attachments/issues_controller_patch.rb')
  load File.join(__dir__, 'lib/redmine_private_attachments/attachments_controller_patch.rb')
  load File.join(__dir__, 'lib/redmine_private_attachments/journal_patch.rb')

  missing_actions = [:show, :download, :thumbnail].reject do |action|
    AttachmentsController.action_methods.include?(action.to_s)
  end
  if missing_actions.any?
    Rails.logger.warn "[redmine_private_attachments] ATTENZIONE: le seguenti action non esistono " \
                      "in AttachmentsController e non sono protette: #{missing_actions.join(', ')}. " \
                      "Verificare la compatibilità del plugin con questa versione di Redmine."
  end
end
