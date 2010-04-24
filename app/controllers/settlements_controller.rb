class SettlementsController < ApplicationController
  def index
    @from, @to = assign_from_to(params)
    @settlements = Settlement.find(:all, :conditions => { :created_at => (@from - 1.day)..@to })
    @taxes = Tax.all
    
    params[:cost_center_id] ||= CostCenter.first.id
    @selected_cost_center = CostCenter.find(params[:cost_center_id])
    
    @cost_centers = CostCenter.all

    @unsettled_orders = Order.find(:all, :conditions => { :settlement_id => nil, :finished => true })
    unsettled_userIDs = Array.new
    @unsettled_orders.each do |uo|
      unsettled_userIDs << uo.user_id
    end
    unsettled_userIDs.uniq!
    @unsettled_users = User.find(:all, :conditions => { :id => unsettled_userIDs })
  end

  def show
    @settlement = Settlement.find params[:id]
    @orders = Order.find_all_by_settlement_id @settlement.id
    @cost_center = CostCenter.find params[:cost_center_id]
    render :new
  end

  def new
    @settlement = Settlement.new
    @settlement.user_id = params[:user_id]
    @orders = Order.find_all_by_settlement_id(nil, :conditions => { :user_id => @settlement.user_id, :finished => true })
  end

  def edit
    @settlement = Settlement.find(params[:id])
    @orders = Order.find_all_by_settlement_id(@settlement.id)
    render :new
  end

  def update
    @settlement = Settlement.find(params[:id])
    @settlement.update_attributes(params[:settlement])
    redirect_to settlements_path
  end

  def create
    @settlement = Settlement.new(params[:settlement])
    @settlement.user_id = params[:user_id]
    @orders = Order.find_all_by_settlement_id(nil, :conditions => { :user_id => @settlement.user_id, :finished => true })
    if @settlement.save
      @orders.each do |so|
        so.settlement_id = @settlement.id
        so.save
      end
      redirect_to settlements_path
    else
      render :new
    end
  end

  private

    def assign_from_to(p)
      f = Date.civil( p[:from][:year ].to_i,
                      p[:from][:month].to_i,
                      p[:from][:day  ].to_i) if p[:from]
      t = Date.civil( p[:to  ][:year ].to_i,
                      p[:to  ][:month].to_i,
                      p[:to  ][:day  ].to_i) if p[:to]

      f ||= (DateTime.now.day - 1).days.ago
      t ||= 0.week.ago

      return f, t
    end

end
