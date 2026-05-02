class CreateCollectionBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :collection_books do |t|
      t.references :collection, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true

      t.timestamps
    end

    add_index :collection_books, [:collection_id, :book_id], unique: true
  end
end
