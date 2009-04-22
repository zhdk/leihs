class Backend::ItemsController < Backend::BackendController
  
  before_filter :pre_load

  def index
    params[:sort] ||= 'model_name'
    params[:dir] ||= 'asc'

    if @model
      items = current_inventory_pool.items.by_model(@model) #old# @model.items & current_inventory_pool.items
    elsif @location
      items = @location.items
    else
      items = current_inventory_pool.items
    end    

#old#
#    case params[:filter]
#      when "in_stock"
#        items = items.in_stock
#      when "not_in_stock"
#        items = items.not_in_stock
#      when "broken"
#        items = items.broken
#      when "incomplete"
#        items = items.incomplete
#      when "unborrowable"
#        items = items.unborrowable
#    end
    if params[:filter]
      filter = params[:filter].to_sym
      filters = Item.scopes.keys #['in_stock', 'not_in_stock', 'broken', 'incomplete', 'unborrowable']
      items = items.send(filter) if filters.include?(filter)
    end
    
    @items = items.search(params[:query], :page => params[:page], :order => params[:sort].to_sym, :sort_mode => params[:dir].to_sym, :include => [:model, :location])
  end

  def show
  end

  def update
    @item.update_attributes(params[:item])
    redirect_to :action => 'show', :id => @item # TODO 24** redirect to the right tab
  end

#################################################################

  def location
    if request.post?
      @item.update_attribute(:location, current_inventory_pool.locations.find(params[:location_id]))
      redirect_to
    end
  end

#################################################################

  def status
  end

#################################################################

  def notes
    if request.post?
      @item.log_history(params[:note], current_user.id)
    end
    @histories = @item.histories
    @item.contract_lines.collect(&:contract).uniq.each do |contract|
      @histories += contract.actions
    end
    @item.contract_lines.each do |cl|
      @histories << History.new(:created_at => cl.start_date, :user => cl.contract.user, :text => _("Item handed over as part of contract %d.") % cl.contract.id) if cl.start_date
      @histories << History.new(:created_at => cl.end_date, :user => cl.contract.user, :text => _("Expected to be returned.")) unless cl.returned_date
    end
    
    #@histories.sort! { |a,b| b.created_at <=> a.created_at }

  end

#################################################################


  private
  
  def pre_load
    params[:id] ||= params[:item_id] if params[:item_id]
    @item = current_inventory_pool.items.find(params[:id]) if params[:id]
    @model = current_inventory_pool.models.find(params[:model_id]) if params[:model_id]
    @location = current_inventory_pool.locations.find(params[:location_id]) if params[:location_id]

    @tabs = []
    @tabs << :location_backend if @location
    @tabs << :model_backend if @model
    @tabs << :item_backend if @item
  end

end
