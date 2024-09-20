class CollectionsController < ApplicationController
  def show
    @books = Collection.paginate(page: params[:page], per_page: 10)

    # Filter based on search & selectors, allowing for multiple filters
    @books = @books.where("title LIKE ?", "%#{params[:title].downcase}%") if params[:title].present?
    @books = @books.where(owner: params[:owner]) if params[:owner].present?
    @books = @books.where(author: params[:author]) if params[:author].present?
    @books = @books.where.associated(:genres).where(genres: { name: params[:genre] }) if params[:genre].present?
  end

  def add
  end

  def create
    genres = params[:genres].split(",").map { |genre| Genre.create(name: genre.strip) }
    book = Collection.create(
      owner: params[:owner],
      title: params[:title],
      author: params[:author]
    )
    genres.each(&:save!)
    book.genres = genres
    book.save!
  end
end
