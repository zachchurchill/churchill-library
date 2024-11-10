class BooksController < ApplicationController
  include SessionsHelper

  before_action :authenticate_user, except: [:show]

  def show
    @owners = Owner.all.sort_by(&:name)
    @authors = Author.all.sort_by(&:name)
    @genres = Genre.all.sort_by(&:name)
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
    book.owner = Owner.find_or_create_by(name: params[:owner].strip.downcase)
    book.author = Author.find_or_create_by(name: params[:author].strip.downcase)
    book.genres = params[:genres].split(",").map { |genre| Genre.find_or_create_by(name: genre.strip.downcase) }
    book.save!
    EmbedBookJob.perform_later(book)
    redirect_to books_path, notice: "\"#{book.title.titleize}\" has been added"
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])
    @book.title = params[:book][:title].strip
    @book.owner = Owner.find_or_create_by(name: params[:book][:owner].strip.downcase)
    @book.author = Author.find_or_create_by(name: params[:book][:author].strip.downcase)
    @book.genres = params[:book][:genres].split(",").map { |genre| Genre.find_or_create_by(name: genre.strip.downcase) }
    if @book.save
      EmbedBookJob.perform_later(@book)
      redirect_to books_path, notice: "\"#{@book.title.titleize}\" has been updated"
    else
      flash.now[:danger] = "Failed to update \"#{@book.title.titleize}\""
      render :edit
    end
  end

  def remove
    @book = Book.find(params[:id])
  end

  def delete
    @book = Book.find(params[:id])
    if @book.destroy
      redirect_to books_path, notice: "\"#{@book.title.titleize}\" has been removed"
    else
      flash.now[:danger] = "Failed to remove \"#{@book.title.titleize}\""
      render :remove
    end
  end
end
