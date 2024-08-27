class Collection < ApplicationRecord
  validates :owner, presence: true, length: { minimum: 3, maximum: 50 }
  validates :title, presence: true, length: { minimum: 3, maximum: 200 }
  validates :author, presence: true, length: { minimum: 3, maximum: 100 }
  validates :genre, allow_blank: true, length: { minimum: 3, maximum: 50 }
end
