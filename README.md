# Redmine Private Attachments

A Redmine plugin that hides attachments added to private notes from users who lack the `view_private_notes` permission.

## How it works

When a user submits an issue update with a private note and one or more attachments, those attachments are automatically marked as private. Users without the `view_private_notes` permission will not see them listed and cannot access them directly via URL.

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

## License

[MIT](LICENSE) — © 2026 Christian Borrello
