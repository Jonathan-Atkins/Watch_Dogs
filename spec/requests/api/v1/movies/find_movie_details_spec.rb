require "rails_helper"

describe "A Movie Detail", type: :request do
  describe "show details of one movie" do
    context "Happy Path" do
      it "returns details of a movie", :vcr do
        movie_id = 278
        get "/api/v1/movies/#{movie_id}"

        expect(response).to be_successful
        expect(response.status).to eq 200

        movie = JSON.parse(response.body, symbolize_names: true)[:data]

        expect(movie[:id]).to eq(movie_id.to_s)
        expect(movie[:type]).to eq("movie")

        attributes = movie[:attributes]
        expect(attributes[:title]).to eq("The Shawshank Redemption")
        expect(attributes[:release_year]).to eq("1994-09-23")
        expect(attributes[:vote_average]).to eq(8.707)
        expect(attributes[:runtime]).to eq(142)
        expect(attributes[:genres]).to eq(["Drama", "Crime"])
        expect(attributes[:summary]).to eq(
          "Imprisoned in the 1940s for the double murder of his wife and her lover, upstanding banker Andy Dufresne begins a new life at the Shawshank prison, where he puts his accounting skills to work for an amoral warden. During his long stretch in prison, Dufresne comes to be admired by the other inmates -- including an older prisoner named Red -- for his integrity and unquenchable sense of hope."
        )

        cast = attributes[:cast]
        expect(cast).to be_an(Array)
        expect(cast.length).to eq(10)  
        expect(cast.first).to have_key(:character)
        expect(cast.first).to have_key(:actor)
      end
    end

    context "Sad Path" do
      it "returns a 404 error when no movies match the search query" do
        invalid_movie_id = 0
        get "/api/v1/movies/#{invalid_movie_id}"

        expect(response.status).to eq(404)

        error_message = JSON.parse(response.body, symbolize_names: true)
        expect(error_message[:message]).to eq("Movie not found")
      end
    end
  end
end