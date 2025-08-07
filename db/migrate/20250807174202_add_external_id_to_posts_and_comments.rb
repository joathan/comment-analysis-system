class AddExternalIdToPostsAndComments < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :external_id, :integer, null: false
    add_column :comments, :external_id, :integer, null: false

    add_index :posts, :external_id, unique: true
    add_index :comments, :external_id, unique: true
  end
end
