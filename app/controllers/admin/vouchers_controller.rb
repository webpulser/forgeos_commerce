class Admin::VouchersController < Admin::BaseController
  def index
    @vouchers = Voucher.all
  end

  def new
    @voucher = Voucher.new(params[:voucher])
    render :action => 'create'
  end

  def create
    @voucher = Voucher.new(params[:voucher])
    if @voucher.save
      flash[:notice] = I18n.t('voucher.create.success').capitalize
      redirect_to(:action => 'index')
    else
      flash[:error] = I18n.t('voucher.create.failed').capitalize
    end
  end

  def show
    @voucher = Voucher.find_by_id(params[:id])
  end

  def edit
    @voucher = Voucher.find_by_id(params[:id])
  end

  def update
    @voucher = Voucher.find_by_id(params[:id])
    if @voucher.update_attributes(params[:voucher])
      flash[:notice] = I18n.t('voucher.update.success').capitalize
    else
      flash[:error] = I18n.t('voucher.update.failed').capitalize
    end
    render :action => 'edit'
  end

  def destroy
    @voucher = Voucher.find_by_id(params[:id])
    if @voucher.destroy
      flash[:notice] = I18n.t('voucher.destroy.success').capitalize
    else
      flash[:error] = I18n.t('voucher.destroy.failed').capitalize
    end
    index
    render :partial => 'list', :locals => { :vouchers => @vouchers }
  end

end
