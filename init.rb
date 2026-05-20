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
end
