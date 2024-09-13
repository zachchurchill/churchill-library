class Collection < ApplicationRecord
  has_and_belongs_to_many :genres
  before_save do
    self.owner = owner.downcase
    self.title = title.downcase
    self.author = author.downcase
  end
  validates :owner, presence: true, length: { minimum: 3, maximum: 50 }
  validates :title, presence: true, length: { minimum: 3, maximum: 200 }
  validates :author, presence: true, length: { minimum: 3, maximum: 100 }

  def self.unique_owners
    Collection.pluck(:owner).uniq
  end

  def self.unique_authors
    Collection.pluck(:author).uniq
  end
end
