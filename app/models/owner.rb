class Owner < ApplicationRecord
  has_many :books

  before_save do
    self.name = name.downcase
  end
  validates :name, presence: true, length: { minimum: 3, maximum: 50 }
end
