class CreateCollectionsForBookLists < ActiveRecord::Migration[7.1]
  def change
    create_table :collections do |t|
      t.references :owner, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description

      t.timestamps
    end
  end
end
