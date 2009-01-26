class Admin::VouchersController < Admin::BaseController
  def index
    @vouchers = Voucher.all
  end

  def create
    @voucher = Voucher.new(params[:voucher])
    if request.post?
      if @voucher.save
        flash[:notice] = 'Voucher was successfully created'
        redirect_to(:action => 'index')
      else
        flash[:error] = @voucher.errors
      end
    end
  end

  def edit
    @voucher = Voucher.find_by_id(params[:id])
    if request.post?
      if @voucher.update_attributes(params[:voucher])
        flash[:notice] = 'Voucher was successfully updated'
      else
        flash[:error] = @voucher.errors
      end
    end
  end

  def show
    @voucher = Voucher.find_by_id(params[:id])
  end

  def destroy
    @voucher = Voucher.find_by_id(params[:id])
    if @voucher.destroy
      index
      render :partial => 'list', :locals => { :vouchers => @vouchers }
    end
  end

end
