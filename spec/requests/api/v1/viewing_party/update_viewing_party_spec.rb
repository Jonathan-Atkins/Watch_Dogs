require 'rails_helper'

RSpec.describe 'Update a Viewing Party', type: :request do
  describe 'update a particular viewing party' do
    before(:each) do
      ViewingPartyUser.destroy_all
      ViewingParty.destroy_all
      User.destroy_all
    end

    let!(:host) { User.create!(name: "Host User", username: "hostuser", password: "password") }
    let!(:invitee1) { User.create!(name: "Invitee One", username: "invitee1", password: "password") }
    let!(:invitee2) { User.create!(name: "Invitee Two", username: "invitee2", password: "password") }
    let!(:invitee3) { User.create!(name: "Invitee Three", username: "invitee3", password: "password") }

    let!(:viewing_party1) do 
      ViewingParty.create!(
        name: "Movie Night", 
        start_time: DateTime.now, 
        end_time: DateTime.now + 4.hours, 
        movie_id: 278, 
        movie_title: "Inception", 
        host_id: host.id
      )
    end

    before do
      ViewingPartyUser.create!(viewing_party_id: viewing_party1.id, user_id: invitee1.id)
      ViewingPartyUser.create!(viewing_party_id: viewing_party1.id, user_id: invitee2.id)
    end

    let(:update_params) do 
      {
        viewing_party: {
          name: "Updated Movie Night",
          movie_id: 238,
          movie_title: "The Godfather"
        },
        invitees: [invitee3.id] 
      }
    end

    context 'Happy Path' do
      it 'updates a valid viewing party and ensures invitees include old and new invitees' do
        patch "/api/v1/viewing_parties/#{viewing_party1.id}", params: update_params
        expect(response.status).to eq 200

        json_response = JSON.parse(response.body, symbolize_names: true)[:data][:attributes]
        expect(json_response[:name]).to eq("Updated Movie Night")
        expect(json_response[:movie_id]).to eq(238)
        expect(json_response[:movie_title]).to eq("The Godfather")
        updated_invitees = ViewingPartyUser.where(viewing_party_id: viewing_party1.id).pluck(:user_id)

        expect(updated_invitees).to contain_exactly(invitee1.id,invitee2.id,invitee3.id)
      end
    end

    context 'Sad Path' do
      it 'returns an error if the viewing party does not exist' do
        patch "/api/v1/viewing_parties/99999", params: update_params
        expect(response.status).to eq 404
        expect(JSON.parse(response.body)['errors']).to include("Viewing Party 99999 Not Found")
      end

      # xit 'returns an error if required fields are missing' do
      #   invalid_params = { viewing_party: { name: "" } }
      #   patch "/api/v1/viewing_parties/#{viewing_party1.id}", params: invalid_params
      #   expect(response.status).to eq 422
      #   expect(JSON.parse(response.body)['errors']).to include("At least one attribute must change")
      # end
    end
  end
end
