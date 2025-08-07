class AddTranslatedBodyToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :comments, :translated_body, :text
  end
end
