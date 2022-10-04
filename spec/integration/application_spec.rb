require "spec_helper"
require "rack/test"
require_relative '../../app'

def reset_albums_table
  seed_sql = File.read('spec/seeds/albums_seeds.sql')
  connection = PG.connect({ host: ENV['HOST'], dbname: 'music_library_test', user: 'postgres', password: ENV['PASSWORD'] })
  connection.exec(seed_sql)
end

RSpec.describe Application do
  include Rack::Test::Methods

  before(:each) do
    reset_albums_table
  end
  
  let(:app) { Application.new }

  context "GET to /albums" do
    it "Returns 200 OK with list of albums" do
      response = get("/albums")

      expected_response = "Doolittle, Surfer Rosa, Waterloo, Super Trouper, Bossanova, Lover, Folklore, I Put a Spell on You, Baltimore, Here Comes the Sun, Fodder on My Wings, Ring Ring"

      expect(response.status).to eq(200)
      expect(response.body).to eq(expected_response)
    end
  end

  context "POST to /albums" do
    it "Returns 200 OK and created new album" do
      response = post("/albums", title: "Voyage", release_year: 2022, artist_id: 2)

      expect(response.status).to eq(200)
      expect(response.body).to eq('')

      response = get("/albums")

      expect(response.status).to eq(200)
      expect(response.body).to include('Voyage')
    end
  end

  context "GET to /artists" do
    it "Returns 200 OK and returns a list of artists" do
      response = get("/artists")

      expected_response = "Pixies, ABBA, Taylor Swift, Nina Simone, Kiasmos"

      expect(response.status).to eq(200)
      expect(response.body).to eq(expected_response)
    end
  end

  context "POST to /artists" do
    it "Returns 200 OK and creates a new artist" do
      response = post("/artists", name: "Wild nothing", genre: "Indie")

      expect(response.status).to eq(200)
      expect(response.body).to eq('')

      response = get("/artists")
      
      expect(response.status).to eq(200)
      expect(response.body).to include('Wild nothing')
    end
  end

end
