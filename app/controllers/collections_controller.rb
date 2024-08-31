class CollectionsController < ApplicationController
  def show
    @books = Collection.paginate(page: params[:page], per_page: 10)
  end
end
