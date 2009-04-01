class Admin::TagsController < Admin::BaseController
  layout false
  before_filter :get_taggable, :exept => [:index]
  def new
    @tag = Tag.new
  end

  def create
    @taggable.tag_list << params[:tag][:name]
    @taggable.save
    render :action => 'update'
  end

  def show
  end

  def edit
  end

  def update
    if params[:taggable] && params[:taggable][:tag_list]
      @taggable.tag_list << params[:taggable][:tag_list]
      @taggable.save
    end
  end

  def destroy
    @taggable.tag_list.remove(params[:tag])
    @taggable.save
    render :action => 'update'
  end

  def selector
    @tags = Tag.all - @taggable.tags
  end

  def index
  end

private
  def get_taggable
    @taggable = eval(params[:type]).find(params[:id])
  end
end
