class Admin::PriceCutsController < Admin::BaseController
  def special_offer
    if params[:rule_builder]
      build_offer
    else
      flash[:error] = 'Fields'
    end
  end

  def get_result
    case "#{params[:target_type]}"
      
      when "Category"
        @categories = Category.find(:all, :select => :name)
        render :update do |page|
          page.show 'rule_builder_target'
          page.replace_html 'rule_builder_target', @categories.collect{ |r| "<option value='#{r.name.to_s}'>#{r.name.to_s}</option>"}
        end
        
      when "Cart"
        @rule_targets = ['Total items quantity', 'Total weight', 'Total amount', 'Shipping method']
        render :update do |page|
          page.hide 'rule_builder_target'
          page.replace_html 'rule_targets_', @rule_targets.collect{ |t| "<option value='#{t}'>#{t}</option>"}
        end
      
      when 'Product in Shop','Product in Cart'
        @product_rule_targets = Product.find(:all).collect{|p| p.product_type.tattributes.collect{|t| t.name}}.uniq        
        @rule_targets = ['Please select','Title','Price','Description','Weight','SKU','Stock']
        @rule_targets += @product_rule_targets  
        render :update do |page|
          page.hide 'rule_builder_target'
          page.replace_html 'rule_targets_', @rule_targets.collect{ |t| "<option value='#{t}'>#{t}</option>"}
        end
      else
        render :nothing => true
    end
  end

  def get_rules_values
    case "#{params[:target_type]}"
    
      when 'Title'
        @rule_values = Product.find(:all)
        render :update do |page|
          page.replace_html 'rule_values_', @rule_values.collect{ |v| "<option value='#{v.name}'>#{v.name}</option>"}
        end
         
      when 'Price','Description','Weight','Stock'
        render :nothing => true
      else
        render :nothing => true
    end
  end

  # GET /price_cuts
  # GET /price_cuts.xml
  def index
    @price_cuts = PriceCut.find(:all)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @price_cuts }
    end
  end
  
  # GET /price_cuts/1
  # GET /price_cuts/1.xml
  def show
    @price_cut = PriceCut.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @price_cut }
    end
  end
  
  # GET /price_cuts/new
  # GET /price_cuts/new.xml
  def new
    @price_cut = PriceCut.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @price_cut }
    end
  end
  
  # GET /price_cuts/1/new
  def edit
    @price_cut = PriceCut.find(params[:id])
  end
  
  # POST /price_cuts
  # POST /price_cuts.xml
  def create
    @price_cut = PriceCut.new(params[:price_cut])
    respond_to do |format|
      if @price_cut.save
        flash[:notice] = I18n.t('price_cut.create.success').capitalize
        format.html { redirect_to(admin_price_cut_path(@price_cut)) }
        format.xml  { render :xml => @price_cut, :status => :created, :location => @price_cut }
      else
        flash[:error] = I18n.t('price_cut.create.failed').capitalize
        format.html { render :action => "new" }
        format.xml  { render :xml => @price_cut.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /price_cuts/1
  # PUT /price_cuts/1.xml
  def update
    @price_cut = PriceCut.find(params[:id])

    respond_to do |format|
      if @price_cut.update_attributes(params[:price_cut])
        flash[:notice] = I18n.t('price_cut.update.success').capitalize
        format.html { redirect_to(admin_price_cut_path(@price_cut)) }
        format.xml  { head :ok }
      else
        flash[:error] = I18n.t('price_cut.update.failed').capitalize
        format.html { render :action => "edit" }
        format.xml  { render :xml => @price_cut.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /price_cuts/1
  # DELETE /price_cuts/1.xml
  def destroy
    @price_cut = PriceCut.find(params[:id])
    if @price_cut && @price_cut.destroy
      flash[:notice] = I18n.t('price_cut.destroy.success').capitalize
    else
      flash[:error] = I18n.t('price_cut.destroy.failed').capitalize
    end

    respond_to do |format|
      format.html { redirect_to url_for(:action => :index) }
      format.xml  { head :ok }
    end
  end

  private
  
  def build_offer
    case params[:for]
    when 'Category'
      rule = Rule.new
      rule.conditions << Category
      rule.save
    when 'Cart'
    end
  end
end
