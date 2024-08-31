class CreateGenres < ActiveRecord::Migration[7.1]
  def change
    remove_column :collections, :genre

    create_table :genres do |t|
      t.string :name
      t.timestamps
    end

    create_table :collections_genres, id: false do |t|
      t.belongs_to :collection
      t.belongs_to :genre
    end
  end
end
