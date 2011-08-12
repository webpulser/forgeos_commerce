class Admin::FormsController < Admin::BaseController
  before_filter :get_form, :only => [:show, :edit, :update, :destroy]
  before_filter :new_form, :only => [:new, :create]
  
  def index
    respond_to do |format|
      format.html
      format.json do
        sort
        render :layout => false
      end
    end
  end

  def show
  end
  
  def edit
  end

  def new
  end
  
  def create
    if @form.save
      flash[:notice] = "Création du formulaire réussi"
      redirect_to([forgeos_commerce, :edit, :admin, @form])
    else
      flash[:error] = "Création du formulaire échoué"
      render :action => :new
    end
  end

private

  def sort
    columns = %w(name model)

    per_page = params[:iDisplayLength].to_i
    offset =  params[:iDisplayStart].to_i
    page = (offset / per_page) + 1
    order = "#{columns[params[:iSortCol_0].to_i]} #{params[:iSortDir_0].upcase}"

    #conditions = { :parent_id => nil }
    options = { :page => page, :per_page => per_page }

    options[:order] = order unless order.squeeze.blank?

    if params[:sSearch] && !params[:sSearch].blank?
      options[:star] = true
      @forms = Form.search(params[:sSearch],options)
    else
      @forms = Form.paginate(:all,options)
    end
  end
  
  def new_form
    @form = Form.new(params[:form])
  end
  
  def get_form
    @form = Form.find(params[:id])
  end
  

end
