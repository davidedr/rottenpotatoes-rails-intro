class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    sort = params[:sort] || session[:sort]
    case sort
    when 'title'
      ordering, @title_header = {:order => :title}, 'hilite'
    when 'release_date'
      ordering, @date_header = {:order => :release_date}, 'hilite'
    end
    @all_ratings = Movie.all_ratings
    logger.debug("@all_ratings: #{@all_ratings}")
    @selected_ratings = params[:ratings] || session[:ratings] || {}
    logger.debug("@selected_ratings: #{@selected_ratings}")
    if params[:sort] != session[:sort]
      session[:sort] = sort
      redirect_to :sort => sort, :ratings => @selected_ratings and return
    end

    if params[:ratings] != session[:ratings] and @selected_ratings != {}
      session[:sort] = sort
      session[:ratings] = @selected_ratings
      redirect_to :sort => sort, :ratings => @selected_ratings and return
    end
    if @selected_ratings == {}
      @movies = Movie.order(sort)
    else
      cond = ""
      @selected_ratings.each do |key, value|
        cond = cond + " OR " unless cond == ''
        cond = cond + "rating='#{key}'"
      end
      @movies = Movie.where(cond).order(sort)
    end
    
  end
  
  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
