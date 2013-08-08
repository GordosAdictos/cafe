class KmlGenerator

  include KmlGeneratorGroup

  EXTENSION = 0.005
  TYPE_OF_CHART = [:by_school, :by_group]
  MULTIPLICADOR = 2

  def initialize(values)
    @political_party_id = values[:political_party_id]
    @public_office_id = values[:public_office_id]
    #@votes_totals = votes_totals
  end

  def generate(type_of_chart=:by_school)

    
    #altura = votos_partido_y_cargo_publico partido, cargo
    
    kml = '<?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2">
        <Document>
          <name>Escuelas</name>
            <Folder>'
    kml << send(type_of_chart)        
    kml <<"</Folder>
        </Document>  
      </kml>    "
    kml
  end

private
  
  # def by_group
  #   # schools_added = []
  #   # @votes_totals.map do | votes_total |
  #   #   next if schools_added.include? votes_total.school.id
  #   #   schools_added << votes_total.school.id

  #   #   altura = votes_total.votes.to_i
  #   #   alt = altura + 1
  #   #   name = votes_total.school.name
  #   #   partido = votes_total.political_party.name
  #   #   cargo = votes_total.public_office.name
  #   #   lat = votes_total.school.lat
  #   #   lon = votes_total.school.lon
  #   #     "
  #   #   <Placemark>
  #   #     #{kml_style_for(altura)}
  #   #     <name>#{name}</name>
  #   #     <description><![CDATA[
  #   #       <h3>votos para #{partido} cargo #{cargo}: #{altura}</h3> 
  #   #     ]]></description>
  #   #     <visibility>1</visibility>
  #   #     <Polygon>
  #   #       <tessellate>1</tessellate>
  #   #       <extrude>1</extrude>
  #   #       <altitudeMode>relativeToGround</altitudeMode>
  #   #       <outerBoundaryIs>
  #   #         <LinearRing>
  #   #           <coordinates>
  #   #             #{lat.to_f+EXTENSION},#{lon},#{alt*MULTIPLICADOR}
  #   #             #{lat},#{lon.to_f+EXTENSION},#{alt*MULTIPLICADOR}
  #   #             #{lat.to_f-EXTENSION},#{lon},#{alt*MULTIPLICADOR}
  #   #             #{lat},#{lon.to_f-EXTENSION},#{alt*MULTIPLICADOR}
  #   #             #{lat.to_f+EXTENSION},#{lon},#{alt*MULTIPLICADOR}
  #   #           </coordinates>
  #   #         </LinearRing>
  #   #       </outerBoundaryIs>
  #   #     </Polygon>
  #   #   </Placemark>
  #   #     "
  #   # end.join
  # end
  
  def by_school
    @votes_totals = VotesTotal.where(public_office_id:@public_office_id).where(political_party_id:@political_party_id)
    @votes_totals.map do | votes_total |
      altura = votes_total.votes.to_i
      alt = altura + 1
      name = votes_total.school.name
      partido = votes_total.political_party.name
      cargo = votes_total.public_office.name
      lat = votes_total.school.lat
      lon = votes_total.school.lon
        "
      <Placemark>
        #{kml_style_for(altura)}
        <name>#{name}</name>
        <description><![CDATA[
          <h3>votos para #{partido} cargo #{cargo}: #{altura}</h3> 
        ]]></description>
        <visibility>1</visibility>
        <Polygon>
          <tessellate>1</tessellate>
          <extrude>1</extrude>
          <altitudeMode>relativeToGround</altitudeMode>
          <outerBoundaryIs>
            <LinearRing>
              <coordinates>
                #{lat.to_f+EXTENSION},#{lon},#{alt*MULTIPLICADOR}
                #{lat},#{lon.to_f+EXTENSION},#{alt*MULTIPLICADOR}
                #{lat.to_f-EXTENSION},#{lon},#{alt*MULTIPLICADOR}
                #{lat},#{lon.to_f-EXTENSION},#{alt*MULTIPLICADOR}
                #{lat.to_f+EXTENSION},#{lon},#{alt*MULTIPLICADOR}
              </coordinates>
            </LinearRing>
          </outerBoundaryIs>
        </Polygon>
      </Placemark>
        "
    end.join
  end

  def kml_style_for(altura)
    color = gradient.kml_colour_at(altura, 'aa')
    "<Style>
       <PolyStyle>
         <color>#{color}</color>            
         <colorMode>normal</colorMode>      
         <fill>1</fill>                     
         <outline>1</outline>         
       </PolyStyle>
     </Style>"
  end

  def gradient
    if @gradient.nil?
      if min_vote == max_vote && max_vote == 0
        @max_vote = 1
      end
      @gradient = ColourGradient.new(min_vote, max_vote, '00ff00', 'ff0000')
    end
    @gradient
  end

  def max_vote
    @max_vote ||= @votes_totals.maximum(:votes).to_i
  end

  def min_vote
    @min_vote ||= @votes_totals.minimum(:votes).to_i
  end

end

