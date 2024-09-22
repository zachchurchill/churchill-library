class BooksController < ApplicationController
  include SessionsHelper

  before_action :authenticate_user, except: [:show]

  def show
    @owners = Owner.all
    @authors = Author.all
    @genres = Genre.all
    @owner = Owner.find_by(id: params[:owner].presence)
    @author = Author.find_by(id: params[:author].presence)
    @genre = Genre.find_by(id: params[:genre].presence)
    @books = Book.paginate(page: params[:page], per_page: 10)

    # Filter based on search & selectors, allowing for multiple filters
    @books = @books.where("title LIKE ?", "%#{params[:title].downcase}%") if params[:title].present?
    @books = @books.where(owner: @owner) unless @owner.nil?
    @books = @books.where(author: @author) unless @author.nil?
    @books = @books.where.associated(:genres).where(genres: { id: @genre }) unless @genre.nil?
  end

  def add
  end

  def create
    book = Book.new(title: params[:title].strip)
    book.create_owner(name: params[:owner].strip)
    book.create_author(name: params[:author].strip)
    genres = params[:genres].split(",").map { |genre| Genre.create(name: genre.strip) }
    book.genres = genres
    book.save
    redirect_to books_path, notice: "\"#{book.title}\" has been added"
  end
end
