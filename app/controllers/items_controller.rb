class ItemsController < ApplicationController

  before_action :set_item, only: [:show, :detail, :edit, :update]

  def index
    @items = Item.order("created_at DESC").limit(10)
  end

  def purchase; end

  def new
    @item = Item.new
    @item.images.build  # itemレコードが保存された際にimageレコードにも保存をかける
    @category_parents = Category.where(ancestry: nil).map{|i| [i.name, i.id]}
    @item_status = Item.item_statuses.keys
    @delivery_charged = Item.delivery_chargeds.keys
    @delivery_area = Prefecture.all
    @delivery_shipping_date = Item.delivery_shipping_dates.keys
  end

  # 親カテゴリーが選択された後に動くアクション
  def get_category_children
    @category_children = Category.find(params[:parent_id]).children    #選択された親カテゴリーに紐付く子カテゴリーの配列を取得
  end

  # 子カテゴリーが選択された後に動くアクション
  def get_category_grandchildren
    @category_grandchildren = Category.find(params[:child_id]).children     #選択された子カテゴリーに紐付く孫カテゴリーの配列を取得
  end

  def show
    @images = @item.images
    @total_price = @item.total_price.to_s(:delimited)
  end

  def edit
    # @output_fee = (@item.total_price/10)
    total_price = @item.total_price
    fee = (@item.total_price) / 10
    @fee = fee.to_s(:delimited)
    @profit = (total_price - fee).to_s(:delimited)
  end

  def detail
    @images = @item.images
  end

  def update
    if @item.update(item_params)
      redirect_to detail_item_path
    else
      render :edit
  end

  end

  def create
    # Item.create(name: item_params[:name], image: item_params[:image], item_status: item_params[:item_status], delivery_charged: item_params[:delivery_charged], delivery_method: item_params[:delivery_method], delivery_area: item_params[:delivery_area], delivery_shipping_date: item_params[:delivery_shipping_date], total_price: item_params[:total_price], item_profile_comment: item_params[:item_profile_comment], item_salse_status: item_params[:item_salse_status], good: item_params[:good], category_id: item_params[:category_id])
    @item = Item.create(item_params)
    redirect_to action: :index
  end

  def pay
    Payjp.api_key = ENV['PAYJP_ACCESS_KEY']
    charge = Payjp::Charge.create(
    amount: 2000000,
    #amountは一旦仮置きで3500とする。
    # 後で amount: @item.total_price,にする
    card: params['payjp-token'],
    currency: 'jpy'
    )
    redirect_to root_path, notice: '決済が完了しました'
  end

  private

  def item_params
    params.require(:item).permit(:name, :image, :item_status, :delivery_charged,:delivery_method, :delivery_area, :delivery_shipping_date, :total_price, :item_profile_comment, :item_salse_status, :good, :category_id, images_attributes: [:id, :image]).merge(seller_id: current_user.id)
  end

  def set_item
    @item = Item.find(params[:id])
  end




end
