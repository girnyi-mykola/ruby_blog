class ArticlesController < ApplicationController

  before_action :authenticate_user!, except: [:index, :show, :tagged, :search]
  
  load_and_authorize_resource

  def index
    @articles = Article.page(params[:page]).order('created_at DESC')
    @custom_paginate_renderer = custom_paginate_renderer
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
    @categories = Category.all.map{|c| [ c.name, c.id ] }
    @category = ''
  end

  def create
    @article = Article.new(article_params)
    @article.category_id = params[:category_id] 
    @article.user = current_user

    if @article.save
      redirect_to @article
    else
      render :new
    end
  end

  def edit
    @article = Article.find(params[:id])
    @categories = Category.all.map{|c| [ c.name, c.id ] }
    @category = @categories.select { |c| c[1].to_f==@article.category_id.to_f }.first
  end

  def update
    @article = Article.find(params[:id])
    @article.category_id = params[:category_id]

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to root_path
  end

  def tagged
    if params[:tag].present? 
      @articles = Article.tagged_with(params[:tag])
    else 
      @articles = Article.postall
    end  
    @articles = @articles.paginate(:page => params[:page], :per_page => 2).order(id: :desc)
    @custom_paginate_renderer = custom_paginate_renderer
  end

  def search  
    if params[:search].blank?  
      redirect_to(root_path, alert: "Empty field!") and return  
    else  
      @parameter = params[:search].downcase  
      @articles = Article.where('lower(title) LIKE :search OR lower(body) LIKE :search', search: "%#{@parameter}%").order(:created_at)
      @articles = @articles.paginate(:page => params[:page], :per_page => 2).order(id: :desc)
      @custom_paginate_renderer = custom_paginate_renderer
    end  
  end

  private
    def article_params
      params.require(:article).permit(:title, :body, :status, :tag_list)
    end

end
