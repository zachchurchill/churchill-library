class CreateBookEmbeddings < ActiveRecord::Migration[7.1]
  def change
    create_table :book_embeddings do |t|
      t.references :book, null: false, foreign_key: true, index: { unique: true }
      t.vector :embedding, limit: 256, null: false

      t.timestamps
    end
  end
end
