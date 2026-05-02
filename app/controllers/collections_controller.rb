class CollectionsController < ApplicationController
  include SessionsHelper

  before_action :authenticate_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_collection, only: [:show, :edit, :update, :destroy]

  def index
    @owner = Owner.find_by(id: params[:owner]) if normalized_owner_id.present?
    @owners = Owner.where(id: Collection.select(:owner_id)).distinct.order(:name)
    @collections = Collection.includes(:owner, books: [:author, :genres]).order(:title)
    @collections = @collections.where(owner: @owner) if @owner.present?
  end

  def show
    @books = @collection.books
  end

  def new
    @collection = Collection.new
    @selected_book_ids = []
    load_form_options
  end

  def create
    @selected_book_ids = normalized_book_ids
    @collection = Collection.new(collection_attributes)
    @collection.books = Book.where(id: @selected_book_ids)

    if @collection.save
      redirect_to collection_path(@collection), notice: "\"#{@collection.title.titleize}\" has been added"
    else
      load_form_options
      flash.now[:danger] = "Failed to add Collection"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @selected_book_ids = @collection.book_ids
    load_form_options
  end

  def update
    @selected_book_ids = normalized_book_ids
    @collection.assign_attributes(collection_attributes)

    if @selected_book_ids.empty?
      @collection.errors.add(:books, "must include at least one book")
      load_form_options
      flash.now[:danger] = "Failed to update \"#{@collection.title.to_s.titleize}\""
      render :edit, status: :unprocessable_entity
      return
    end

    saved = false
    Collection.transaction do
      @collection.books = Book.where(id: @selected_book_ids)
      saved = @collection.save
      raise ActiveRecord::Rollback unless saved
    end

    if saved
      redirect_to collection_path(@collection), notice: "\"#{@collection.title.titleize}\" has been updated"
    else
      load_form_options
      flash.now[:danger] = "Failed to update \"#{@collection.title.to_s.titleize}\""
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    title = @collection.title.titleize

    if @collection.destroy
      redirect_to collections_path, notice: "\"#{title}\" has been removed"
    else
      @selected_book_ids = @collection.book_ids
      load_form_options
      flash.now[:danger] = "Failed to remove \"#{title}\""
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_collection
    @collection = Collection.includes(books: [:owner, :author, :genres]).find(params[:id])
  end

  def normalized_owner_id
    owner_id = params[:owner].to_s.strip
    return unless owner_id.match?(/\A[1-9]\d*\z/)

    owner_id
  end

  def collection_attributes
    {
      owner: Owner.find_by(id: normalized_collection_owner_id),
      title: collection_params[:title].to_s.strip,
      description: collection_params[:description].to_s.strip.presence
    }
  end

  def collection_params
    params.fetch(:collection, {})
  end

  def normalized_collection_owner_id
    owner_id = collection_params[:owner_id].to_s.strip
    return unless owner_id.match?(/\A[1-9]\d*\z/)

    owner_id
  end

  def normalized_book_ids
    Array(collection_params[:book_ids])
      .map { |book_id| book_id.to_s.strip }
      .select { |book_id| book_id.match?(/\A[1-9]\d*\z/) }
      .map(&:to_i)
      .uniq
  end

  def load_form_options
    @owners = Owner.order(:name)
    @books = Book.includes(:owner, :author, :genres).order(:title)
  end
end
