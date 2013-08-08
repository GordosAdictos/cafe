class MapsController < ApplicationController

  def index
  
  end

  def kml
    
    # votes = VotesTotal.where(public_office_id:params[:public_office]).where(political_party_id:params[:political_party])
    # kg = KmlGenerator.new votes
    # send_data kg.generate(:by_group), filename: "votes.kml", type: "application/xml"

    kg = KmlGenerator.new public_office_id:params[:public_office],political_party_id:params[:political_party]
    send_data kg.generate(:by_group), filename: "votes.kml", type: "application/xml"
    
  end
end