class Api::V1::ViewingPartiesController < ApplicationController
  def create
    viewing_party = ViewingParty.new(viewing_party_params)

    if viewing_party.save
      if params[:invitees].present?
        invite_guests(params[:invitees],viewing_party)
      else
        return render json: { errors: ["Invitees can't be blank"] }, status: :unprocessable_entity
      end
      render json: ViewingPartySerializer.new(viewing_party), status: :created
    else
      render json: { errors: viewing_party.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    begin
      viewing_party = ViewingParty.find(params[:id])
      viewing_party.update!(viewing_party_params)
      invite_guests(params[:invitees], viewing_party) if params[:invitees]
    
      render json: ViewingPartySerializer.new(viewing_party), status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { errors: ["Viewing Party #{params[:id]} Not Found"] }, status: :not_found
    rescue StandardError => e
      render json: { errors: [e.message] }, status: :unprocessable_entity
    end
  end

  def show
    viewing_party = ViewingParty.find(params[:id])
    if viewing_party
      render json: ViewingPartySerializer.new(viewing_party), status: :ok
    else
      render json: { errors: ["Viewing Party not found"] }, status: :not_found
    end
  end

  private

  def viewing_party_params
    params.require(:viewing_party).permit(:name, :start_time, :end_time, :movie_id, :movie_title, :host_id)
  end

  def invite_guests(invitees, viewing_party)
    invitees.each do |invitee_id|
      ViewingPartyUser.create!(viewing_party_id: viewing_party.id, user_id: invitee_id)
    end
  end
end