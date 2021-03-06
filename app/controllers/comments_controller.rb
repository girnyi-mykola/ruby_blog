class CommentsController < ApplicationController
  
  before_action :authenticate_user!, except: [:show]

  load_and_authorize_resource
  
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params.merge(:user => current_user))
    @comment.user = current_user
    redirect_to article_path(@article)
  end

  def destroy
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])
    @comment.destroy
    redirect_to article_path(@article)
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status)
    end
end
