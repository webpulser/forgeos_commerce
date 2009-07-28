class Admin::TattributeValuesController < Admin::BaseController
  before_filter :get_tattribute
  before_filter :get_tattribute_value, :except => [:new, :create, :index]
 
  def new
    @tattribute_value = @tattribute.tattribute_values.new(params[:tattribute_value])
    render('create')
  end

  # Create a Attribute
  # ==== Params
  # * tattribute_id = Tattribute's id
  # * attribute = Hash of Attribute's attributes
  def create
    @tattribute_value = @tattribute.tattribute_values.new(params[:tattribute_value])
    if @tattribute_value.save
      flash[:notice] = I18n.t('tattribute_value.create.success').capitalize
      redirect_to([:edit, :admin , @tattribute])
    else
      flash[:error] = I18n.t('tattribute_value.create.failed').capitalize
    end
  end

  def update
    if @tattribute_value.update_attributes(params[:tattribute_value])
      flash[:notice] = I18n.t('tattribute_value.update.success').capitalize
      return redirect_to([:edit, :admin, @tattribute_value.attributes_tattribute])
    else
      flash[:error] = I18n.t('tattribute_value.update.failed').capitalize
    end
    render('edit')
  end

  # Destroy a Attribute
  # ==== Params
  # * id = Attribute's id
  def destroy
    tattribute = @tattribute_value.tattribute
    if @tattribute_value.destroy
      flash[:notice] = I18n.t('tattribute_value.destroy.success').capitalize
      render(:partial => 'list', :locals => { :tattribute => tattribute })
    else
      flash[:error] = I18n.t('tattribute_value.destroy.failed').capitalize
    end
  end

private
  def get_tattribute
    @tattribute = Tattribute.find_by_id(params[:id]) || Tattribute.find_by_id(params[:tattribute_id])

    if @tattribute.dynamic
      flash[:warning] = I18n.t('tattribute.create.dynamic').capitalize
      return redirect_to([:edit, :admin, tattribute])
    end
  end

  def get_tattribute_value
    @tattribute_value = @tattribute.tattribute_values.find_by_id(params[:tattribute_id])
  end

end
