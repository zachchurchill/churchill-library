class RemoveCollections < ActiveRecord::Migration[7.1]
  def change
    drop_table :collections_genres
    drop_table :collections
  end
end
