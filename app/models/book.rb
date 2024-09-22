class Book < ApplicationRecord
  belongs_to :owner
  belongs_to :author
  has_and_belongs_to_many :genres

  before_save do
    self.title = title.downcase
  end
  validates :title, presence: true, length: { minimum: 3, maximum: 200 }
end
