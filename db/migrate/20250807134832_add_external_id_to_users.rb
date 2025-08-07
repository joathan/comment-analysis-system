class AddExternalIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :external_id, :integer
    add_index :users, :external_id
  end
end
