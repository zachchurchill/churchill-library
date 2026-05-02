class Book < ApplicationRecord
  belongs_to :owner
  belongs_to :author
  has_and_belongs_to_many :genres
  has_one :book_embedding
  has_many :collection_books, dependent: :destroy
  has_many :collections, through: :collection_books

  before_save do
    self.title = title.downcase
  end
  before_destroy :destroy_genres, :destroy_embedding
  after_destroy :destroy_owner, :destroy_author
  validates :title, presence: true, length: { minimum: 4, maximum: 200 }

  def to_s
    owner = self.owner.name
    author = self.author.name
    genres = self.genres.map(&:name).join(", ")
    "#{owner} owns #{title} written by #{author} under the genres of #{genres}"
  end

  private

  def destroy_owner
    owner.destroy unless owner.books.where.not(id: self).present? || owner.collections.present?
  end

  def destroy_author
    author.destroy unless author.books.where.not(id: self).present?
  end

  def destroy_embedding
    book_embedding&.destroy
  end

  def destroy_genres
    genres.each do |genre|
      genre.destroy unless genre.books.where.not(id: self).present?
    end
  end
end
