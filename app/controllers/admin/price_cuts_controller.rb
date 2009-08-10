class Admin::PriceCutsController < Admin::BaseController
  def special_offer
    return flash[:error] = 'Fields' unless params[:rule_builder]

    #build_offer
    
    # GENERATE RULE !!!!!!!
    # Parameters: {"commit"=>"Save", "rule_builder"=>{"stop"=>"0",   "title"=>"", "if"=>"Any", "target"=>"Computer", "description"=>"", "for"=>["Product"]}, 
    #             "authenticity_token"=>"JZ3F3oEKmMB0rhQf6xHljskHTDH2aPP53unToh3SLwU=", "end_offer"=>"1", 
    #             "end"=>{"targets"=>["Total number of offer use"], "values"=>["324"], "conds"=>["Is"]}, 
    #             "end_offer_if"=>"Any", "act"=>{"targets"=>["Offer a product"], "values"=>["Macbook"]}, 
    #             "rule"=>{"targets"=>["Price", "Stock"], "values"=>["24", "100"], "conds"=>["==", "=="]}}
    
    
    @main_attributes = %w(price title description weight sKU stock)

    @rule_condition = []
    @rule_condition << params[:rule_builder]['for'] << ':product'
    
    # Build Action variables
    variables = {}
    params[:act][:targets].each_with_index do |action, index|
      case "#{action}"
      when "Discount price this product"
        variables[:discount] = params[:act][:values][index].to_i
        variables[:fixed_discount] = (params[:act][:conds][index] == "By percent" ? false : true)
      when "Offer a product"
        variables[:product_ids] = [params[:act][:values][index].to_i]
      when "Offer free delivery"
        variables[:shipping_ids] = params[:act][:values][index]
      end
    end     

    if params[:rule_builder]['if'] == 'All'
      @rule = SpecialOfferRule.new
      @rule.name = params[:rule_builder][:name]
      @rule.description = params[:rule_builder][:description]

      
      params[:rule][:targets].each_with_index do |rule_target, index|
        rule_target.downcase!
        if @main_attributes.include?(rule_target)
          target = "m.#{rule_target}"
        else  
          target = "m.get_attribute(#{rule_target})"
        end

        if params[:rule][:values][index].to_i == 0
          value = "'#{params[:rule][:values][index]}'"
        else
          value = params[:rule][:values][index]
        end

        @rule_condition << "#{target}.#{params[:rule][:conds][index]}(#{value})"
      end
     
      @rule.conditions = "[#{@rule_condition.join(', ')}]" 
      @rule.variables = variables
      @rule.save
    else
      params[:rule][:targets].each_with_index do |rule_target, index|
        @rule = SpecialOfferRule.new
        @rule.name = params[:rule_builder][:name]
        @rule.description = params[:rule_builder][:description]

        rule_condition = @rule_condition
        
        rule_target.downcase!
        if @main_attributes.include?(rule_target)
          target = "m.#{rule_target}"
        else  
          target = "m.get_attribute(#{rule_target})"
        end

        if params[:rule][:values][index].to_i == 0
          value = "'#{params[:rule][:values][index]}'"
        else
          value = params[:rule][:values][index]
        end

        rule_condition << "#{target}.#{params[:rule][:conds][index]}(#{value})"
       
        @rule.conditions = "[#{rule_condition.join(', ')}]" 
        @rule.variables = variables
        @rule.save
      end
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
end
