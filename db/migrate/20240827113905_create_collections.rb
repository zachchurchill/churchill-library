class CreateCollections < ActiveRecord::Migration[7.1]
  def change
    create_table :collections do |t|
      t.string :owner
      t.string :title
      t.string :author
      t.string :genre

      t.timestamps
    end
    add_index :collections, :owner
  end
end
