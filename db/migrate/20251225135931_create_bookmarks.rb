class CreateBookmarks < ActiveRecord::Migration[8.0]
  def change
    create_table :bookmarks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :url
      t.string :tag

      t.timestamps
    end
  end
end
