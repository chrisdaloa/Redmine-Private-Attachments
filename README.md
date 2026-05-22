# Redmine Private Attachments

A Redmine plugin that hides attachments added to private notes from users who lack the `view_private_notes` permission.

## How it works

When a user submits an issue update with a private note and one or more attachments:

- The attachments are automatically marked as private
- Users without `view_private_notes` cannot see them in the attachment list
- Users without `view_private_notes` cannot download them directly via URL
- The journal entries ("File added / File deleted") are also hidden from the issue history and properties panel

Deleting a private attachment also keeps the deletion entry hidden from unauthorized users.

## Requirements

- Redmine 5.0.0 or higher (Rails 6.1)

## Installation

```bash
cd /path/to/redmine/plugins
git clone https://github.com/chrisdaloa/Redmine-Private-Attachments.git redmine_private_attachments
cd /path/to/redmine
bundle install
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

Restart Redmine after installation.

## Uninstallation

```bash
bundle exec rake redmine:plugins:migrate NAME=redmine_private_attachments VERSION=0 RAILS_ENV=production
rm -rf plugins/redmine_private_attachments
```

## Permissions

The plugin relies on the built-in Redmine `view_private_notes` permission. No additional configuration is needed — manage access through your existing roles under **Administration → Roles and permissions**.

## Migrating existing data

If the plugin was installed on an instance that already has private attachments or journal entries created before the plugin was active, run this one-time cleanup script to fix historical records:

```bash
bundle exec rails runner "
JournalDetail.where(property: 'attachment').includes(:journal).find_each do |detail|
  next if detail.journal.private_notes

  attachment = Attachment.find_by(id: detail.prop_key)

  should_be_private = attachment ? attachment.private? : begin
    journal = detail.journal
    Journal.where(
      journalized_type: journal.journalized_type,
      journalized_id:   journal.journalized_id,
      private_notes:    true
    ).where('DATE(created_on) = DATE(?)', journal.created_on).exists?
  end

  detail.journal.update_column(:private_notes, true) if should_be_private
end
puts 'Done'
" RAILS_ENV=production
```

## Compatibility warning

At startup, the plugin checks that the `show`, `download`, and `thumbnail` actions exist in `AttachmentsController`. If any are missing after a Redmine upgrade, a warning is logged:

```
[redmine_private_attachments] ATTENZIONE: le seguenti action non esistono in AttachmentsController...
```

Check the log with:

```bash
docker logs <container_name> 2>&1 | grep redmine_private_attachments
# or
tail -f /path/to/redmine/log/production.log | grep redmine_private_attachments
```

If the warning appears after a Redmine upgrade, review the plugin's `attachments_controller_patch.rb` before using it in production.

## License

[MIT](LICENSE) — © 2026 Christian Borrello
