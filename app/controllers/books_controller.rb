class BooksController < ApplicationController
  include SessionsHelper

  PER_PAGE = 10
  FILTER_MODELS = {
    "owner" => Owner,
    "author" => Author,
    "genre" => Genre
  }.freeze

  before_action :authenticate_user, except: [:show]

  def show
    @filters = normalized_filters
    @canonical_query = canonical_query(@filters)
    @canonical_path = books_path(@canonical_query)

    response.set_header("X-Canonical-Url", @canonical_path)

    if request.format.html? && !turbo_stream_request? && request.query_parameters != @canonical_query
      redirect_to @canonical_path, status: :see_other
      return
    end

    @owner = Owner.find_by(id: @filters["owner"]) if @filters["owner"].present?
    @author = Author.find_by(id: @filters["author"]) if @filters["author"].present?
    @genre = Genre.find_by(id: @filters["genre"]) if @filters["genre"].present?

    @books = filtered_books(@filters)
             .includes(:owner, :author, :genres)
             .paginate(page: @filters["page"], per_page: PER_PAGE)

    @owners = owner_options
    @authors = author_options
    @genres = genre_options

    respond_to do |format|
      format.html
      format.turbo_stream
    end
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
    redirect_to books_path, status: :see_other, notice: "\"#{book.title.titleize}\" has been added"
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
      redirect_to books_path, status: :see_other, notice: "\"#{@book.title.titleize}\" has been updated"
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
      redirect_to books_path, status: :see_other, notice: "\"#{@book.title.titleize}\" has been removed"
    else
      flash.now[:danger] = "Failed to remove \"#{@book.title.titleize}\""
      render :remove
    end
  end

  private

  def normalized_filters
    filters = {}
    title = params[:title].to_s.strip
    filters["title"] = title if title.present?

    FILTER_MODELS.each do |param_name, model|
      id = normalized_id(params[param_name])
      filters[param_name] = id if id.present? && model.exists?(id: id)
    end

    page = normalized_page(params[:page])
    filters["page"] = page if page.present?

    filters
  end

  def normalized_id(value)
    value = value.to_s.strip
    return unless value.match?(/\A[1-9]\d*\z/)

    value.to_i.to_s
  end

  def normalized_page(value)
    page = normalized_id(value)
    return if page.blank? || page == "1"

    page
  end

  def canonical_query(filters)
    filters.slice("title", "owner", "author", "genre", "page")
  end

  def filtered_books(filters)
    books = Book.all

    if filters["title"].present?
      escaped_title = ActiveRecord::Base.sanitize_sql_like(filters["title"].downcase, "!")
      books = books.where("LOWER(books.title) LIKE ? ESCAPE '!'", "%#{escaped_title}%")
    end

    books = books.where(owner_id: filters["owner"]) if filters["owner"].present?
    books = books.where(author_id: filters["author"]) if filters["author"].present?
    books = books.joins(:genres).where(genres: { id: filters["genre"] }) if filters["genre"].present?
    books.distinct
  end

  def owner_options
    owners = Owner.where(id: filtered_books(@filters.except("owner")).select(:owner_id))
    owners = owners.or(Owner.where(id: @owner.id)) if @owner.present?
    owners.distinct.order(:name)
  end

  def author_options
    authors = Author.where(id: filtered_books(@filters.except("author")).select(:author_id))
    authors = authors.or(Author.where(id: @author.id)) if @author.present?
    authors.distinct.order(:name)
  end

  def genre_options
    books = filtered_books(@filters.except("genre")).joins(:genres)
    genres = Genre.where(id: books.select("genres.id"))
    genres = genres.or(Genre.where(id: @genre.id)) if @genre.present?
    genres.distinct.order(:name)
  end

  def turbo_stream_request?
    request.headers["Accept"].to_s.include?(Mime[:turbo_stream].to_s)
  end
end
