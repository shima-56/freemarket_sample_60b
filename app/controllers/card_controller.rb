class CardController < ApplicationController
  require "payjp"
  include CommonActions
  before_action :set_categories
  
  def new
    card = Card.where(user_id: current_user.id)
    redirect_to action: "show" if card.exists?
  end

  def pay #payjpとCardのデータベース作成を実施します。
    Payjp.api_key = ENV["PAYJP_ACCESS_KEY"]
    if params['payjp-token'].blank?
      redirect_to action: "new"
    else
      user_id = current_user.id
      customer = Payjp::Customer.create(
      description: '登録テスト', 
      card: params['payjp-token'],
      ) 
      @card = Card.new(user_id: user_id, customer_id: customer.id, card_id: customer.default_card)
      if @card.save
        path = Rails.application.routes.recognize_path(request.referer)
        if path[:controller] == "card" && path[:action] == "new"
          redirect_to action: "show"
        else
          redirect_to finish_signup_index_path
        end
      else
        redirect_to action: "pay"
      end
    end
  end

  def delete #PayjpとCardデータベースを削除します
    card = Card.where(user_id: current_user.id).first
    if card.blank?
    else
      Payjp.api_key = ENV["PAYJP_ACCESS_KEY"]
      customer = Payjp::Customer.retrieve(card.customer_id)
      customer.delete
      card.delete
    end
      redirect_to action: "new"
  end

  def show #Cardのデータpayjpに送り情報を取り出します
    card = Card.where(user_id: current_user.id).first
    if card.blank?
      redirect_to action: "new" 
    else
      Payjp.api_key = ENV["PAYJP_ACCESS_KEY"]
      customer = Payjp::Customer.retrieve(card.customer_id)
      @default_card_information = customer.cards.retrieve(card.card_id)
    end
  end
end
