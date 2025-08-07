class MoviesController < ApplicationController
  def index
    movies_scope = Movie.joins(:shows).where('start_time > ?',Time.current).distinct.order(:created_at)
    @pagy, @movies = pagy(movies_scope, limit: 5)
  end
  def show
    @movie = Movie.find(params[:id])
    shows_scope = @movie.shows.where("start_time > ?", Time.current).order(start_time: :desc)
    @pagy, @shows = pagy(shows_scope, limit: 5)
  end

end
