class Genre < ApplicationRecord
  has_and_belongs_to_many :collections
  has_and_belongs_to_many :books
  before_save do
    self.name = name.downcase
  end
  validates :name, length: { minimum: 3, maximum: 50 }

  def self.unique_genres
    Genre.pluck(:name).uniq
  end
end
