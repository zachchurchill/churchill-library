class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.string :title
      t.references :owner, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: true

      t.timestamps
    end

    create_table :books_genres, id: false do |t|
      t.belongs_to :book
      t.belongs_to :genre
    end
  end
end
