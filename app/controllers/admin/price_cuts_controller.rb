class Admin::PriceCutsController < Admin::BaseController
  def special_offer
    if params[:rule_builder]
      #build_offer
      
      # GENERATE RULE !!!!!!!
      # Parameters: {"commit"=>"Save", "rule_builder"=>{"stop"=>"0",   "title"=>"", "if"=>"Any", "target"=>"Computer", "description"=>"", "for"=>["Product"]}, 
      #             "authenticity_token"=>"JZ3F3oEKmMB0rhQf6xHljskHTDH2aPP53unToh3SLwU=", "end_offer"=>"1", 
      #             "end"=>{"targets"=>["Total number of offer use"], "values"=>["324"], "conds"=>["Is"]}, 
      #             "end_offer_if"=>"Any", "act"=>{"targets"=>["Offer a product"], "values"=>["Macbook"]}, 
      #             "rule"=>{"targets"=>["Price", "Stock"], "values"=>["24", "100"], "conds"=>["==", "=="]}}
      
      
      @main_attributes = ['price','title','description', 'weight', 'sKU', 'stock']

      @rule_condition = "[#{params[:rule_builder]['for']}, :p, "    
      @count = 0
      @nb_rules = params[:rule][:targets].count
      if params[:rule_builder]['if'] == 'All'
        @rule = Rule.new
        params[:rule][:targets].each do |rule_target|
          rule_target.downcase!
          if @main_attributes.include?(rule_target)
            @rule_condition += "m.#{rule_target}"
          else  
             @rule_condition += "m.get_attribute(#{rule_target})"
          end

         
          @rule_condition += params[:rule][:conds][@count]
          if params[:rule][:values][@count].to_i == 0
            @rule_condition += "'#{params[:rule][:values][@count]}'"
          else
            @rule_condition += params[:rule][:values][@count]
          end
          @rule_condition += "," if @count != @nb_rules-1
          @count += 1
        end
        @rule_condition += "]"
        @rule.conditions = @rule_condition
        @rule.name = params[:rule_builder][:title]
        @rule.description = params[:rule_builder][:description]
        
        
        @nb=0
        @action =""
        params[:act][:targets].each do |action|
        
          case "#{action}"
            when "Discount price this product"
            @action += "Discount_product"
            if params[:act][:conds][@nb] == "By percent"
              @action += "(#{params[:act][:values][@nb]},'percent')"
            else
              @action += "(#{params[:act][:values][@nb]})"
            end
            when "Offer a product"
             @action += "Offer_product(#{params[:act][:values][@nb]})"
            when "Offer free delivery"
             @action += "Offer_delivery"
          end
        @nb +=1
        end
        
        
        @rule.save
      else
        params[:rule][:targets].each do |rule_target|
          rule_target.downcase!
          @rule = Rule.new
          @rule_condition2 = @rule_condition 
          if @main_attributes.include?(rule_target)
            @rule_condition2 += "m.#{rule_target}"
          else  
             @rule_condition2 += "m.get_attribute('#{rule_target}')"
          end
          @rule_condition2 += params[:rule][:conds][@count]
          if params[:rule][:values][@count].to_i == 0
            @rule_condition2 += "'#{params[:rule][:values][@count]}'"
          else
            @rule_condition2 += params[:rule][:values][@count]
          end
          @rule_condition2 += "]"
          
           @nb=0
            @action =""
            params[:act][:targets].each do |action|

              case "#{action}"
                when "Discount price this product"
                @action += "Discount_product"
                if params[:act][:conds][@nb] == "By percent"
                  @action += "(#{params[:act][:values][@nb]},'percent')"
                else
                  @action += "(#{params[:act][:values][@nb]})"
                end
                when "Offer a product"
                 @action += "Offer_product(#{params[:act][:values][@nb]})"
                when "Offer free delivery"
                 @action += "Offer_delivery"
              end
            @nb +=1
            end
          
          @rule.conditions = @rule_condition2
          @rule.name = params[:rule_builder][:title]
          @rule.description = params[:rule_builder][:description]

          @rule.save
          @count +=1
        end
      end
    else
      flash[:error] = 'Fields'
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
