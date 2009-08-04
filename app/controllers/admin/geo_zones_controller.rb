# This Controller Manage GeoZones
class Admin::GeoZonesController < Admin::BaseController
  before_filter :new_geo_zone, :only => [:create, :new]
  before_filter :get_geo_zone, :except => [:create, :new, :index]
  
  # List GeoZones like a Tree.
  def index
    @geo_zones = GeoZone.find_all_by_parent_id(nil)
  end

  def new
    render :layout => false
  end

  # Create a GeoZone
  # ==== Params
  # * geo_zone = Hash of GeoZone's attributes
  #
  # The GeoZone can be a child of another GeoZone.
  def create
    if @geo_zone.save
      flash[:notice] = I18n.t('geo_zone.create.success').capitalize
    else
      flash[:error] = I18n.t('geo_zone.create.failed').capitalize
    end
    render :action => 'new', :layout => false
  end

  # Edit a GeoZone
  # ==== Params
  # * id = GeoZone's id to edit
  # * geo_zone = Hash of GeoZone's attributes
  #
  # The GeoZone can be a child of another GeoZone.
  def edit
    render :layout => false
  end
 
  def update
    if @geo_zone.update_attributes(params[:geo_zone])
      flash[:notice] = I18n.t('geo_zone.update.success').capitalize
    else
      flash[:error] = I18n.t('geo_zone.update.failed').capitalize
    end
    render :action => 'edit', :layout => false
  end
  # Destroy a GeoZone
  # ==== Params
  # * id = ProductGeoZone's id
  # ==== Output
  #  if destroy succed, return the GeoZones list
  def destroy
    if @geo_zone.destroy
      flash[:notice] = I18n.t('geo_zone.destroy.success').capitalize
    else
      flash[:error] = I18n.t('geo_zone.destroy.failed').capitalize
    end
    render(:update) do |page|
      display_standard_flashes
    end
  end
private
  def get_geo_zone
    unless @geo_zone = GeoZone.find_by_id(params[:id])
      flash[:error] = I18n.t('geo_zone.not_exist').capitalize
      redirect_to admin_geo_zones_path
    end
  end

  def new_geo_zone
    @geo_zone = GeoZone.new(params[:geo_zone])
  end
end
