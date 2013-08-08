require 'ostruct'
module KmlGeneratorGroup

  def by_group
    
    @votes_totals = VotesTotal.where(public_office_id:@public_office_id).where(political_party_id:@political_party_id)
      .joins(:school)
      .select('*, "schools"."group" as "group"')
      .order('"group"')

    groups = @votes_totals.group_by(&:group) 
    groups.map do |group_name, votes|
      name = group_name
      altura = votes.map{|v| v.votes.to_i}.sum
      alt = altura + 1
      lat = votes.map{|v| v.school.lat.to_f}.sum / votes.size
      lon = votes.map{|v| v.school.lon.to_f}.sum / votes.size
      
      lista_escuelas = votes.map{|v| "<li>#{v.school.name.humanize}</li>"}.join
      
      coordinates = schools_to_polygon(votes.map(&:school), alt) 
      
      "
      <Placemark>
        #{kml_style_for(altura)}
        <name>#{name}</name>
        <description><![CDATA[
          Cantidad de votos: <h4>#{altura}</h4>
          Escuelas:
          <ul>
            #{lista_escuelas}
          </ul>
        ]]></description>
        <visibility>1</visibility>
        <Polygon>
          <tessellate>1</tessellate>
          <extrude>1</extrude>
          <altitudeMode>relativeToGround</altitudeMode>
          <outerBoundaryIs>
            <LinearRing>
              <coordinates>
                #{coordinates}
              </coordinates>
            </LinearRing>
          </outerBoundaryIs>
        </Polygon>
      </Placemark>
        "
    end.join
  end

  def schools_to_polygon(schools, alt)
    
    if schools.size < 3
      lat = schools.first.lat
      lon = schools.first.lon
      "#{lat.to_f+KmlGenerator::EXTENSION},#{lon},#{alt*KmlGenerator::MULTIPLICADOR}
      #{lat},#{lon.to_f+KmlGenerator::EXTENSION},#{alt*KmlGenerator::MULTIPLICADOR}
      #{lat.to_f-KmlGenerator::EXTENSION},#{lon},#{alt*KmlGenerator::MULTIPLICADOR}
      #{lat},#{lon.to_f-KmlGenerator::EXTENSION},#{alt*KmlGenerator::MULTIPLICADOR}
      #{lat.to_f+KmlGenerator::EXTENSION},#{lon},#{alt*KmlGenerator::MULTIPLICADOR}
      "
    else
    
      points = schools.map do |school|
        point = OpenStruct.new
        point.x = school.lat.to_f
        point.y = school.lon.to_f
        point
      end
      ordenated_points = ConvexHull.calculate(points)
      ordenated_points << ordenated_points.first
      ordenated_points.map do |point|
      "#{point.x},#{point.y},#{alt*KmlGenerator::MULTIPLICADOR}"
      end.join(?\n)
    end
  end
end






