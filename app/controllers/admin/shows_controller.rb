class Admin::ShowsController < ApplicationController# frozen_
  # string_literal: true
  before_action :require_admin_login
  def show
    @show = Show.includes(:bookings, :hall, :movie).find(params[:id])
    bookings_scope = @show.bookings.includes(:seats, :user).order(created_at: :desc)
    if @show.nil?
      flash[:notice] = "Show not found"
      render :new
      return
    end
    @pagy, @bookings = pagy(bookings_scope, limit: 2)
  end
  def destroy
    @show = Show.find(params[:id])
    @movie = Movie.find(@show.movie_id)
    if @show.destroy
      flash[:notice] = "Show deleted"
      redirect_to admin_movies_path @movie
    else
      flash[:notice] = "Show not found"
      render :new
    end
  end
  def new
    @show = Show.new
    @movie = Movie.find(params.require :movie_id)
    @halls = Hall.all
  end
  def create
    start_time = Time.zone.parse("#{params[:show][:date]} #{params[:show][:start_time]}")
    movie = Movie.find(params[:show][:movie_id])
    end_time = start_time+ movie.duration.minutes

    @show = Show.new(
      movie_id: params[:show][:movie_id],
      hall_id: params[:show][:hall_id],
      start_time: start_time,
      end_time: end_time
    )
    @movie = Movie.find(@show.movie_id)
    @halls = Hall.all
    if @show.save
      flash[:notice] = "Show created"
      redirect_to admin_movie_path(@movie)
    else
      flash[:notice] = @show.errors.full_messages
      render :new
    end
  end
  def edit
    @show = Show.find(params[:id])
    @movie = @show.movie
    @halls = Hall.all
  end
  def update
    @show = Show.find(params[:id])
    start_time = Time.zone.parse("#{params[:show][:date]} #{params[:show][:start_time]}")
    movie = @show.movie
    end_time = start_time + movie.duration.minutes

    if @show.update(
      hall_id: params[:show][:hall_id],
      start_time: start_time,
      end_time: end_time
    )
      flash[:notice] = "Show updated"
      redirect_to admin_show_path(@show)   # Redirect to show details page
    else
      flash.now[:alert] = @show.errors.full_messages.to_sentence
      @movie = @show.movie
      @halls = Hall.all
      render :edit
    end
  end


end