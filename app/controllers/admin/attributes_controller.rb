# This Controller Manage Attributes and his association with
# Attribute Values
class Admin::AttributesController < Admin::BaseController

  before_filter :get_attributes, :only => [:index]
  before_filter :get_attribute, :only => [:edit, :update, :destroy, :show, :duplicate]
  before_filter :new_attribute, :only => [:new, :create]
  
  # List attributes
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

  def new
  end
 
  def duplicate
    @attribute = @attribute.clone
    render :new
  end

  # Create an attribute
  # ==== Params
  # * attribute = Hash of attribute's attributes
  def create
    if @attribute.save
      flash[:notice] = I18n.t('attribute.create.success').capitalize
      redirect_to edit_admin_attribute_path(@attribute)
    else
      flash[:error] = I18n.t('attribute.create.failed').capitalize
      render :action => :new
    end
  end
  
  # Edit an attribute
  # ==== Params
  # * id = attribute's id
  def edit
  end

  def update
    if @attribute.update_attributes(params[:attribute])
      flash[:notice] = I18n.t('attribute.update.success').capitalize
    else
      flash[:error] = I18n.t('attribute.update.failed').capitalize
    end
    render :action => :edit
  end

  # Destroy an attribute
  # ==== Params
  # * id = attribute's id
  def destroy
    if @attribute.destroy
      flash[:notice] = I18n.t('attribute.destroy.success').capitalize
    else
      flash[:error] = I18n.t('attribute.destroy.failed').capitalize
    end
    return redirect_to(admin_attributes_path)
  end

  def access_method
    render :text => Forgeos::url_generator(params[:access_method])
  end

private
  def get_attributes
    @attributes = Attribute.all
  end
  
  def get_attribute
    unless @attribute = Attribute.find_by_id(params[:id])
      flash[:error] = I18n.t('attribute.not_exist').capitalize
      return redirect_to(admin_attributes_path)
    end
    %w(checkbox_attribute picklist_attribute radiobutton_attribute
       text_attribute longtext_attribute number_attribute
       date_attribute url_attribute).each do |key|
      
    params[:attribute] = params[key] if params[key]
    end
  end
  
  def new_attribute
    case params[:type]
    when 'checkbox'
      params[:attribute] = params[:checkbox_attribute] if params[:checkbox_attribute]
      @attribute = CheckboxAttribute.new(params[:attribute])
    when 'radiobutton'
      params[:attribute] = params[:radiobutton_attribute] if params[:radiobutton_attribute]
      @attribute = RadiobuttonAttribute.new(params[:attribute])
    when 'picklist'
      params[:attribute] = params[:picklist_attribute] if params[:picklist_attribute]
      @attribute = PicklistAttribute.new(params[:attribute])
    when 'text'
      params[:attribute] = params[:text_attribute] if params[:text_attribute]
      @attribute = TextAttribute.new(params[:attribute])
    when 'longtext'
      params[:attribute] = params[:longtext_attribute] if params[:longtext_attribute]
      @attribute = LongtextAttribute.new(params[:attribute])
    when 'number'
      params[:attribute] = params[:number_attribute] if params[:number_attribute]
      @attribute = NumberAttribute.new(params[:attribute])
    when 'date'
      params[:attribute] = params[:date_attribute] if params[:date_attribute]
      @attribute = DateAttribute.new(params[:attribute])
    when 'url'
      params[:attribute] = params[:url_attribute] if params[:url_attribute]
      @attribute = UrlAttribute.new(params[:attribute])
    else
      @attribute = Attribute.new(params[:attribute])
    end
  end

  def sort
    columns = %w(attributes.type attribute_translations.name access_method)
    if params[:sSearch] && !params[:sSearch].blank?
      columns = %w(type name access_method)
    end

    per_page = params[:iDisplayLength].to_i
    offset =  params[:iDisplayStart].to_i
    page = (offset / per_page) + 1
    order = "#{columns[params[:iSortCol_0].to_i]} #{params[:iSortDir_0].upcase}"

    conditions = {}
    options = { :page => page, :per_page => per_page }

    if params[:category_id]
      conditions[:categories_elements] = { :category_id => params[:category_id] }
      options[:include] = :attribute_categories
    end

    options[:conditions] = conditions unless conditions.empty?
    options[:order] = order unless order.squeeze.blank?
    options[:joins] = :translations

    if params[:sSearch] && !params[:sSearch].blank?
      options[:index] = "attribute_core.attribute_#{ActiveRecord::Base.locale}_core"
      options[:sql_order] = options.delete(:order)
      options[:star] = true
      @attributes = Attribute.search(params[:sSearch],options)
    else
      options[:group] = :attribute_id
      @attributes = Attribute.paginate(:all,options)
    end
  end
end
