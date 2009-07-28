class Admin::PriceCutsController < Admin::BaseController
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