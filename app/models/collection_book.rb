class CollectionBook < ApplicationRecord
  belongs_to :collection
  belongs_to :book

  validates :book_id, uniqueness: { scope: :collection_id }
end
