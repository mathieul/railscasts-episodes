class PagesController < ApplicationController
  def index
    @pages = Page.all
  end
  
  def show
    @page = Page.get(params[:id])
  end
  
  def new
    @page = Page.new
    @page.parent_id = params[:parent_id] if params[:parent_id]
  end
  
  def create
    @page = Page.new(params[:page])
    if @page.save
      flash[:notice] = "Successfully created page."
      redirect_to @page
    else
      render :action => 'new'
    end
  end
  
  def edit
    @page = Page.get(params[:id])
  end
  
  def update
    @page = Page.get(params[:id])
    if @page.update_attributes(params[:page])
      flash[:notice] = "Successfully updated page."
      redirect_to @page
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @page = Page.get(params[:id])
    @page.destroy
    flash[:notice] = "Successfully destroyed page."
    redirect_to pages_url
  end
end
