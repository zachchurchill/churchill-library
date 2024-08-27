class Collection < ApplicationRecord
  before_save do
    self.owner = name.downcase
    self.title = name.downcase
    self.author = name.downcase
    self.genre = name.downcase
  end
  validates :owner, presence: true, length: { minimum: 3, maximum: 50 }
  validates :title, presence: true, length: { minimum: 3, maximum: 200 }
  validates :author, presence: true, length: { minimum: 3, maximum: 100 }
  validates :genre, allow_blank: true, length: { minimum: 3, maximum: 50 }

  def self.unique_owners
    Collection.pluck(:owner).uniq
  end

  def self.unique_authors
    Collection.pluck(:author).uniq
  end
end