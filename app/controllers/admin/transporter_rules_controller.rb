class Admin::TransporterRulesController < Admin::BaseController

  before_filter :new_transporter, :only => [:new, :create]
  before_filter :get_transporter, :only => [ :show, :edit, :update, :destroy, :duplicate ]
  before_filter :get_rules, :only => [ :show, :edit ]
  before_filter :get_product_types, :only => [ :new, :create, :show, :edit, :duplicate ]
  before_filter :get_geo_zones, :only => [ :new, :create, :show, :edit, :duplicate ]

  def index
    respond_to do |format|
      format.html
      format.json do
        sort
        render :layout => false
      end
    end
  end

  def categories
    respond_to do |format|
      format.json do
        # list categories like a tree
        render :json => GeoZone.find_all_by_parent_id(nil).collect{ |g| g.to_jstree(:transporter_rules)}.to_json
      end
    end
  end

  def show
  end
  
  def new
  end
  
  def duplicate
    @transporter = @transporter.clone
    render :action => 'new'
  end

  def create
    result = true

    @shipping_methods = params[:shipping_method]

    @shipping_methods.each do |shipping_method|
      new_shipping_method = defined?(@parent_id) ? TransporterRule.new : TransporterRule.new(params[:transporter_rule])

      rule_condition = build_conditions(shipping_method)

      new_shipping_method.conditions = "[#{rule_condition.join(', ')}]"
      new_shipping_method.variables = shipping_method[1][:price][0]

      result = new_shipping_method.save
      
      unless defined?(@parent_id)
        @parent_id = new_shipping_method.id
      else
        new_shipping_method.update_attribute(:parent_id, @parent_id)
      end
    end

    if result
      flash[:notice] = I18n.t('transporter.create.success').capitalize
      render :action => :edit
    else
      flash[:error] = I18n.t('transporter.create.failed').capitalize
      render :action => :new
    end
  end
  
  def edit
  end

  # TODO Fix bug when deleting the two (or more) first rules, the first isn't destroy, but the second (& others) yes | Check order of index in the hash params[:shipping_method]
  def update

    result = true
    parent_transporter_deleted = false
    @parent_id = @transporter.id

    # Get rules to delete
    @transporters_to_delete = params[:shipping_methods_to_delete]
    unless @transporters_to_delete.nil?
      @transporters_to_delete.each do |item_id|
          transporter = TransporterRule.find_by_id(item_id)
          if transporter == @transporter
            parent_transporter_deleted = true
            @transporter_name = transporter.name
            @transporter_description = transporter.description
          else
            parent_transporter_deleted = false
            transporter.destroy
          end
      end
    end

    # Get new & existing rules, create or update
    @shipping_methods = params[:shipping_method]

    @shipping_methods.each do |shipping_method|

      rule_condition = build_conditions shipping_method
      transporter_id = shipping_method[0]

      # If rule exists
      if new_shipping_method = TransporterRule.find_by_id(transporter_id)
        result = new_shipping_method.update_attribute(:conditions, "[#{rule_condition.join(', ')}]")
        result = new_shipping_method.update_attribute(:variables, shipping_method[1][:price][0])
        # Get the new parent_id & update name/description to this one
        check_parent_transporter parent_transporter_deleted, shipping_method, new_shipping_method
        
        result = new_shipping_method.update_attribute(:parent_id, @parent_id) if new_shipping_method.id != @parent_id
        
      else
        
        # If delivery type change
        if @delivery_type != params[:delivery_type] && shipping_method == @shipping_methods.first
          new_shipping_method = TransporterRule.find_by_id(@parent_id)
          result = new_shipping_method.update_attribute(:conditions, "[#{rule_condition.join(', ')}]")
          result = new_shipping_method.update_attribute(:variables, shipping_method[1][:price][0])
          result = new_shipping_method.update_attribute(:parent_id, @parent_id)
          
        else
          new_shipping_method = TransporterRule.new

          new_shipping_method.conditions = "[#{rule_condition.join(', ')}]"
          new_shipping_method.variables = shipping_method[1][:price][0]

          result = new_shipping_method.save
          
          # Get the new parent_id & update name/description to this one
          check_parent_transporter parent_transporter_deleted, shipping_method, new_shipping_method
          result = new_shipping_method.update_attribute(:parent_id, @parent_id)
          
        end
      end
    end

    # Destroy the parent transporter at the end
    @transporter.destroy if parent_transporter_deleted

    if result
      flash[:notice] = I18n.t('transporter.update.success').capitalize
      redirect_to :action => :edit
    else
      flash[:error] = I18n.t('transporter.update.failed').capitalize
      render :action => :edit
    end
  end

  def destroy
    if @transporter.destroy
      flash[:notice] = I18n.t('transporter.destroy.success').capitalize
    else
      flash[:error] = I18n.t('transporter.destroy.failed').capitalize
    end
    redirect_to(admin_transporters_path)
  end

  def activate
    render :text => @transporter.activate
  end
  
  private
    def get_transporter
      unless @transporter = TransporterRule.find_by_id(params[:id])
        flash[:notice] = I18n.t('transporter.not_exist').capitalize
        return redirect_to(admin_transporters_path)
      end
    end

    def new_transporter
      @transporter = TransporterRule.new(params[:transporter_rule])
    end

    def get_rules
      @rules = parse_transporters
    end

    def build_conditions shipping_method
      rule_condition = []
      if params[:delivery_type] == "weight"
        rule_condition << 'Cart'
      else
        rule_condition << 'Product' 
      end
      rule_condition << ':cart'

      shipping_method[1][:values].each_with_index do |value, index|

        case params[:delivery_type]
          when 'weight'
            condition = "m.#{params[:delivery_type]}"
          when 'geo_zone'
            condition = "m.geo_zone_id"
          when 'product_type'
            condition = "m.product_type_id"
          when 'product'
            condition = "m.id"
        end

        condition += ".#{shipping_method[1][:conds][index]}(#{value})"
        rule_condition << condition
      end
      rule_condition
    end

    def parse_transporters

      @delivery_type = get_delivery_type

      transporters = []
      transporters << @transporter
      @transporter.children.collect{ |transporter| transporters << transporter }

      rules = {}
      transporters.each do |transporter|

        db_condition = transporter.conditions
        array_db_condition = db_condition.split(',')
        conditions = []
        conditions << array_db_condition[2]
        conditions << array_db_condition[3] unless array_db_condition[3].nil?

        transporter_rules = {}
        conditions.each_with_index do |condition, _index|
          hash_rule = {}

          array_condition = condition.split('.')
          operator_value = array_condition[2]

          hash_rule[:value] = operator_value[/\-?\d+/]
          hash_rule[:operator] = operator_value[0, operator_value.index('(')]
          transporter_rules[_index] = hash_rule
        end

        rules[transporter.id] = transporter_rules
        rules[transporter.id][:price] = transporter.variables

      end
      rules.sort
    end
    
    def get_product_types
      @product_types = ProductType.all(:include => :globalize_translations , :order => 'product_type_translations.name' ).collect{|c| [c.name, c.id]}
    end

    def get_geo_zones
      @geo_zones = GeoZone.all( :order => :printable_name ).collect{|c| [c.name, c.id]}
    end
      
    def get_delivery_type
      db_delivery_type = @transporter.conditions.split('.')[1]

      case db_delivery_type
        when 'weight'
          @delivery_type = db_delivery_type
        when 'geo_zone_id'
          @delivery_type = 'geo_zone'
        when 'product_type_id'
          @delivery_type = 'product_type'
        when 'id'
          @delivery_type = 'product'
      end

      @delivery_type
    end

    def check_parent_transporter(parent_transporter_deleted, shipping_method, new_shipping_method)

      if parent_transporter_deleted && shipping_method == @shipping_methods.first
        @parent_id = new_shipping_method.id
        new_shipping_method.update_attribute(:name, @transporter_name)
        new_shipping_method.update_attribute(:description, @transporter_description)
        new_shipping_method.update_attribute(:parent_id, nil)
      end
      
    end
    
    def sort
      columns = %w(id name active)

      per_page = params[:iDisplayLength].to_i
      offset =  params[:iDisplayStart].to_i
      page = (offset / per_page) + 1
      order = "rules.#{columns[params[:iSortCol_0].to_i]} #{params[:iSortDir_0].upcase}"

      options = {
        :include => :geo_zones ,
        :conditions => { :parent_id => nil },
        :order => order,
        :page => page,
        :per_page => per_page
      }
      
      options[:conditions] = ['geo_zones_transporter_rules.geo_zone_id = ?', params[:category_id]] if params[:category_id]
            
      if params[:sSearch] && !params[:sSearch].blank?
        @transporters = TransporterRule.search(params[:sSearch],options)
      else
        @transporters = TransporterRule.paginate(:all,options)
      end
    end
end
