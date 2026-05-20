class AddPrivateToAttachments < ActiveRecord::Migration[6.1]
  def up
    add_column :attachments, :private, :boolean, default: false, null: false
  end

  def down
    remove_column :attachments, :private
  end
end
