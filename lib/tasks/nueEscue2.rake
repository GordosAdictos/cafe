
require 'pry'
require 'geocoder'


task :traerEscue2 => :environment do

soloDirNue = []
soloNameNue = []

escueNue = Marshal.load File.read("localesSUM.txt")
escueNueLimit = escueNue.take(264)

aestan = []
bestan = []
estanH = {}
asignados = {}

rango = *(0..(escueNue.count-1))


escueNueLimit. each do |es|
	soloDirNue.push es[1]
end

escueNueLimit. each do |es|
  soloNameNue.push es[0]
end



schools = School.all.map { |school| school.address }

rangoEscViej = *(0..(schools.count-1))

soloDirNue.each_with_index do |nue , ind|
  schools.each_with_index do |sch , otrInd|
   
    if nue.squish.include? sch.squish
      # bestan.push ind
      # estanH[ind] = ind
      asignados[ind] = otrInd
      # p ind.to_s + "::::::"+  nue +"--------"+ otrInd.to_s + "::::::::::"+sch      
    end

  end

end


schoName = School.all.map { |school| school.name }
schoTod = School.all.map { |school| school }

soloNameNue.each_with_index do |nue , ind|
  schoName.each_with_index do |sch , otrInd|


    if sch.squish.include? nue.squish
      # aestan.push ind
      # estanH[ind] = ind
      asignados[ind] = otrInd
    end
    
  end
end
 

############  Harcodeando escuelas con nombres no coincidentes pero que están en la lista
asignados[7] = 8
asignados[83] = 82
asignados[120] = 119
asignados[135] = 122
asignados[129] = 126
asignados[140] = 133
asignados[166] = 147
asignados[151] = 162
asignados[169] = 167
asignados[180] = 174
asignados[214] = 208
# asignados[] =
asignados[138] = 128
asignados[186] = 179

######


noEncontradas = rango.reject{|x| asignados.keys.include? x}

viejasSueltas = rangoEscViej.reject{|x| asignados.values.include? x}

orden = asignados.sort_by {|_key, value| _key}



# noEncontradas.each do |noe|
#       p noe
#       p soloDirNue[noe]
# end
# p "------------------------"
# viejasSueltas. each do |suel|
#   p suel
#   p schoName[suel]

# end


escueNue.each_with_index do |es , ind|
  unless asignados[ind] == nil
  #binding.pry

    escueNue[ind][5] = schoTod[asignados[ind]].lat
    escueNue[ind][6] = schoTod[asignados[ind]].lon
  end
end




noEncontradas.each do |indNoe|
  coord = Geocoder.coordinates(soloDirNue[indNoe][0..-10] + ", Rosario, Santa Fe, Argentina")

  escueNue[indNoe][5] =coord[0].to_s
  escueNue[indNoe][6] =coord[1].to_s

end

  binding.pry


end

	