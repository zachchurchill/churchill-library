# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_10_25_015636) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "vector"

  create_table "authors", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "book_embeddings", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.vector "embedding", limit: 256, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_book_embeddings_on_book_id", unique: true
  end

  create_table "books", force: :cascade do |t|
    t.string "title"
    t.bigint "owner_id", null: false
    t.bigint "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_books_on_author_id"
    t.index ["owner_id"], name: "index_books_on_owner_id"
  end

  create_table "books_genres", id: false, force: :cascade do |t|
    t.bigint "book_id"
    t.bigint "genre_id"
    t.index ["book_id"], name: "index_books_genres_on_book_id"
    t.index ["genre_id"], name: "index_books_genres_on_genre_id"
  end

  create_table "genres", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "owners", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.index ["name"], name: "index_users_on_name", unique: true
  end

  add_foreign_key "book_embeddings", "books"
  add_foreign_key "books", "authors"
  add_foreign_key "books", "owners"
end
