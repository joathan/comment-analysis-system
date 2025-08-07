class RenameWordToTermInKeywords < ActiveRecord::Migration[5.2]
  def change
    rename_column :keywords, :word, :term
  end
end
