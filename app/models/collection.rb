class Collection < ApplicationRecord
  belongs_to :owner
  has_many :collection_books, dependent: :destroy
  has_many :books, through: :collection_books

  before_save do
    self.title = title.downcase
  end

  validates :title, presence: true
  validate :must_include_book

  private

  def must_include_book
    errors.add(:books, "must include at least one book") if books.empty?
  end
end
