# file: app.rb
require 'sinatra'
require "sinatra/reloader"
require_relative 'lib/database_connection'
require_relative 'lib/album_repository'
require_relative 'lib/artist_repository'

DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/album_repository'
    also_reload 'lib/artist_repository'
  end

  get '/albums' do
    repo =  AlbumRepository.new
    
    @albums = repo.all

    erb(:albums)
  end

  post '/albums' do
    if album_invalid_request_parameters? 
      status 400
      return ''
    end

    repo =  AlbumRepository.new
    album = Album.new

    album.title = params[:title]
    album.release_year = params[:release_year]
    album.artist_id = params[:artist_id]

    repo.create(album)

    erb(:album_created)
  end

  get '/albums/new' do
    erb(:new_album)
  end

  get '/artists' do
    repo = ArtistRepository.new

    @artists = repo.all

    erb(:artists)
  end

  post '/artists' do
    if artist_invalid_request_parameters?
      status 400
      return ''
    end

    repo = ArtistRepository.new
    
    artist = Artist.new
    artist.name = params[:name]
    artist.genre = params[:genre]

    repo.create(artist)

    erb(:artist_created)
  end

  get '/artists/new' do
    erb(:new_artist)
  end



  get '/albums/:id' do
    artist_repo = ArtistRepository.new
    album_repo = AlbumRepository.new

    @album = album_repo.find(params[:id])

    @artist = artist_repo.find(@album.id)
    
    erb(:album)
  end

  get '/artists/:id' do
    artist_repo = ArtistRepository.new

    @artist = artist_repo.find(params[:id])

    erb(:artist)
  end

  private

  def album_invalid_request_parameters?
    params[:title] == nil || params[:release_year] == nil || params[:artist_id] == nil
  end

  def artist_invalid_request_parameters?
    params[:name] == nil || params[:genre] == nil 
  end

end