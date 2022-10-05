require "spec_helper"
require "rack/test"
require_relative '../../app'

def reset_albums_table
  seed_sql = File.read('spec/seeds/albums_seeds.sql')
  connection = PG.connect({ host: ENV['HOST'], dbname: 'music_library_test', user: 'postgres', password: ENV['PASSWORD'] })
  connection.exec(seed_sql)
end

def reset_artists_table
  seed_sql = File.read('spec/seeds/artists_seeds.sql')
  connection = PG.connect({ host: ENV['HOST'], dbname: 'music_library_test', user: 'postgres', password: ENV['PASSWORD'] })
  connection.exec(seed_sql)
end


RSpec.describe Application do
  include Rack::Test::Methods

  before(:each) do
    reset_albums_table
    reset_artists_table
  end
  
  let(:app) { Application.new }

  context "GET to /albums" do
    it "Returns 200 OK with list of albums" do
      response = get("/albums")

      expect(response.status).to eq(200)
      expect(response.body).to include('<a href="/albums/1">Doolittle</a>')
      expect(response.body).to include('<a href="/albums/2">Surfer Rosa</a>')
    end
  end

  context "GET to /albums/new" do
    it "Returns 200 OK and returns a form" do
      response = get("/albums/new")

      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Add an album</h1>')
    end
  end

  context "POST to /albums" do
    it "Returns 200 OK and created new album" do
      response = post("/albums", title: "Voyage", release_year: 2022, artist_id: 2)

      expect(response.status).to eq(200)
      expect(response.body).to include('<p>Album was created!</p>')

      response = get("/albums")

      expect(response.status).to eq(200)
      expect(response.body).to include('Voyage')
    end

    it "Returns 400 status if parameters are invalid" do
      response = post("/albums", release_year: 2022, artist_id: 2)

      expect(response.status).to eq(400)
      expect(response.body).to eq('')
    end

  end

  context "GET to /artists" do
    it "Returns 200 OK and returns a list of artists" do
      response = get("/artists")

      expect(response.status).to eq(200)
      expect(response.body).to include('<a href="/artists/1">Pixies</a>')
      expect(response.body).to include('<a href="/artists/2">ABBA</a>')
    end
  end

  context "POST to /artists" do
    it "Returns 200 OK and creates a new artist" do
      response = post("/artists", name: "Wild nothing", genre: "Indie")

      expect(response.status).to eq(200)
      expect(response.body).to include('Artist was created!')

      response = get("/artists")

      expect(response.status).to eq(200)
      expect(response.body).to include('Wild nothing')
    end

    it "Returns 400 if invalid parameters" do
      response = post("/artists", genre: "Indie")

      expect(response.status).to eq(400)
      expect(response.body).to include('')
    end
  end

  context "GET to /artists/new" do
    it "Returns 200 OK and a form" do
      response = get("/artists/new")

      expect(response.status).to eq(200)
      expect(response.body).to include("<h1>Add an artist</h1>")
    end
  end


  context "GET to /albums/:id" do
    it "Returns 200 OK with info about a single album" do
      response = get("/albums/1")

      expect(response.status).to eq(200)
      expect(response.body).to include("<h1>Doolittle</h1>")
      expect(response.body).to include("Artist: Pixies")
    end
  end

  context "GET to /artists/:id" do
    it "Returns 200 OK with info about a single artist" do
      response = get("/artists/1")

      expect(response.status).to eq(200)
      expect(response.body).to include("<h1>Pixies</h1>")
      expect(response.body).to include("Genre: Rock")
    end
  end



end
