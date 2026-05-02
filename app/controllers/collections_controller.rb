class CollectionsController < ApplicationController
  include SessionsHelper

  before_action :authenticate_user, only: [:new, :create]

  def index
    @owner = Owner.find_by(id: params[:owner]) if normalized_owner_id.present?
    @owners = Owner.where(id: Collection.select(:owner_id)).distinct.order(:name)
    @collections = Collection.includes(:owner, books: [:author, :genres]).order(:title)
    @collections = @collections.where(owner: @owner) if @owner.present?
  end

  def show
    @collection = Collection.includes(books: [:owner, :author, :genres]).find(params[:id])
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

  private

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
