class Author < ApplicationRecord
  has_many :books

  before_save do
    self.name = name.downcase
  end
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
end
