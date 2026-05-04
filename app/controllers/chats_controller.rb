class ChatsController < ApplicationController
  before_action :authenticate_user

  def create
    @messages = parsed_history
    message = params[:message].to_s.strip

    if message.blank?
      render :create, status: :unprocessable_entity
      return
    end

    result = Librarian::ChatService.new.call(message: message, history: @messages)
    @messages = result.messages

    render :create, status: result.failed? ? :service_unavailable : :ok
  end

  private

  def parsed_history
    JSON.parse(params[:history].presence || "[]")
  rescue JSON::ParserError
    []
  end
end
