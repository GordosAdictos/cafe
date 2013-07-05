require 'nokogiri'
require 'pry'


desc "Import all the information"
task :import => :environment do
  CARGO_PUBLICO = %w[GOBERNADOR DIPUTADOS SENADOR INTENDENTE CONCEJAL]
  f = File.open("dires_con_harcod2.xml")
  xml_object = Nokogiri::XML(f)
  base = xml_object.children.first.children
  ActiveRecord::Base.transaction do
    base.each do |escuela|
      escuela = escuela.children.first.children
      school = School.where(name:escuela[0].text).try(:first)
      if school.nil?
        school = School.new
        school.name = escuela[0].text
        #school.range = xml[1].text
        school.address = escuela[2].text
        unless escuela[3].children.first.nil?
          school.lat = escuela[3].children.last.text
          school.lon = escuela[3].children.first.text
        else
          next
        end
        school.save!
      end

      escuela[4].children.each do |resultados_por_partido|
        political_party = PoliticalParty.where(name:resultados_por_partido.name).try(:first)
        if political_party.nil?
          political_party = PoliticalParty.new
          political_party.name = resultados_por_partido.name 
          political_party.save!
        end
        resultados_por_partido.children.each_with_index.map do |v, i| 
          public_office_name = CARGO_PUBLICO[i]
          public_office = PublicOffice.where(name:public_office_name.humanize).try(:first)
          if public_office.nil?
            public_office = PublicOffice.new
            public_office.name = public_office_name
            public_office.save!
          end
          total = v.text.to_i
          votes_total = VotesTotal.new
          votes_total.school_id = school.id
          votes_total.political_party_id = political_party.id
          votes_total.public_office_id = public_office.id
          votes_total.votes = total
          votes_total.save!
        end
      end
    end
  end
end
