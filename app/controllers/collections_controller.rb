class CollectionsController < ApplicationController
  def index
    @owner = Owner.find_by(id: params[:owner]) if normalized_owner_id.present?
    @owners = Owner.where(id: Collection.select(:owner_id)).distinct.order(:name)
    @collections = Collection.includes(:owner, :books).order(:title)
    @collections = @collections.where(owner: @owner) if @owner.present?
  end

  def show
    @collection = Collection.includes(books: [:owner, :author, :genres]).find(params[:id])
    @books = @collection.books
  end

  private

  def normalized_owner_id
    owner_id = params[:owner].to_s.strip
    return unless owner_id.match?(/\A[1-9]\d*\z/)

    owner_id
  end
end
