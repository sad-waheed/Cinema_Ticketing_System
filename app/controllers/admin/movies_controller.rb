class Admin::MoviesController < ApplicationController
  before_action :require_admin_login
  before_action :set_movie, only: [:show, :edit, :update, :destroy]

  def new
    @movie = Movie.new
  end

  def create
    permitted_params = params.require(:movie).permit(:title, :rating, :duration, :image)
    @movie = Movie.new(permitted_params.except(:image))
    @movie.image = permitted_params[:image] if permitted_params[:image].present?

    if @movie.save
      flash[:success] = "#{@movie.title} was successfully created."
      redirect_to admin_movies_path
    else
      flash[:error] = @movie.errors.full_messages
      redirect_to admin_movies_path
    end
  end

  def edit
    # @movie is set by before_action :set_movie
  end

  def update
    permitted_params = params.require(:movie).permit(:title, :rating, :duration, :image)

    if permitted_params[:image].present?
      @movie.image = permitted_params[:image]
    end

    if @movie.update(permitted_params.except(:image))
      flash[:success] = "#{@movie.title} was successfully updated."
      redirect_to admin_movie_path(@movie)
    else
      flash.now[:error] = @movie.errors.full_messages
      render :edit
    end
  end

  def show
    shows_scope = @movie.shows
    if shows_scope.empty?
      flash[:notice] = "No shows scheduled for this movie yet."
      return
    end
    @pagy, @shows = pagy(shows_scope.order(:start_time), limit: 2)
  end

  def destroy
    if @movie.destroy
      flash[:notice] = "Movie deleted"
      redirect_to admin_movies_path
    else
      flash[:notice] = "Movie could not be deleted"
      redirect_to admin_movies_path
    end
  end

  def index
    movie_scope = Movie.all
    if movie_scope.empty?
      flash.now[:notice] = "No movies found"
      @movie = Movie.new
      render :new
      return
    end
    @pagy, @movies = pagy(movie_scope.order(:created_at), limit: 2)
  end

  private

  def set_movie
    @movie = Movie.find(params[:id])
  end
end
