class MessagesController < ApplicationController
  def show
    @message = MessageThreadQuery.new(message_id: params[:id]).call
  end
end
