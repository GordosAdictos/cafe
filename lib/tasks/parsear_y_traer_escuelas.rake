
require 'pry'
require 'geocoder'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require "rails"



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




task :parsearPdf => :environment do

  f = File.open("loc.htm")
  doc = Nokogiri::HTML(f)
  tabla = doc.css("td")


  cantCeld = tabla.count
  rango = * (14122 .. 18280)

  errores = []
  fin = "3531"



  acumulador = []
  arrLimpio = []

  #binding.pry

  rango.each_with_index do |nroCeld, indexo|
    unless doc.css("td")[nroCeld].text.blank?

      acumulador.push doc.css("td")[nroCeld].text

        if acumulador [-1].to_i != 0
          if acumulador [-2].to_i != 0
            if acumulador [-3].to_i != 0

              if acumulador[-1].to_i-1 == acumulador[-2].to_i - acumulador[-3].to_i 
              
                # unless acumulador[-2] ==nil
                #   unless fin.to_i = (acumulador[-2].to_i)-1
                #     binding.pry
                #   end
                # end
                unless acumulador[-4].include? "TOTAL"
                    
                  arrLimpio.push acumulador[-5]

                  arrLimpio.push acumulador[-4]#[0..-10]
                  
                  arrLimpio.push acumulador[-3]
                  
                  arrLimpio.push acumulador[-2]
                  
                  arrLimpio.push acumulador[-1]
        
                  "-------------------"
                  if (acumulador[-3].to_i) -1 != fin.to_i
                  p acumulador[-3]
                  p fin
                    binding.pry
                  end
                  # p acumulador[-3]
                  # p fin
                   fin = acumulador[-2]
                end

              end
            end
          end
        end

    end
      

  end


  b = arrLimpio .each_slice(5).to_a

  serialized_array = Marshal.dump(b)

  File.open('localesSUM.txt', 'wb') {|f| f.write(serialized_array) }



end


	

task :parsearDiputados => :environment do

  vinculosRosario = ["http://www.resultados.gob.ar/paginas/paginaspdf/ICIR21013.htm" , "http://www.resultados.gob.ar/paginas/paginaspdf/ICIR21014.htm"]

   arrTodo = []
  vinculosRosario.each do |vin|
    

    arrSeccion = []
    pagCircuitos = Nokogiri::HTML(open(vin))
    vinCircuitosPre = pagCircuitos.css("a")


    vinCircuitos = []

    vinCircuitosPre.each_with_index do |cadaPre , ind|

      circ = pagCircuitos.css("a")[ind]["href"]
      vinCircuitos.push circ
    end

    
    
    #circuitosDeMesas.each do |vinculo|


    vinCircuitos.each do |vinculo|
      p vinculo

      

      pagMesas = Nokogiri::HTML(open("http://www.resultados.gob.ar/paginas/paginaspdf/#{vinculo}"))
      vinMesasPre = pagMesas.css("a")


      vinMesas = []

      vinMesasPre.each_with_index do |cadaPre , ind|

        circ = pagMesas.css("a")[ind]["href"]
        vinMesas.push circ
      end

      arrCircui = []
      
      vinMesas.each do |mesa|


        unless mesa == "21/013/0333/210130333_4028.htm"


          pagPrue = Nokogiri::HTML(open("http://www.resultados.gob.ar/paginas/paginaspdf/#{mesa}"))

          

          pagPrueTod = pagPrue.xpath("//*")

       

          cantNodos = pagPrueTod.count
          arrCantNodos = * (0..cantNodos)
          alternadorKeysVAlues = 0
          hashResultados = {}
          partidoEnUso = ""

          if pagPrueTod[28] == nil
            p mesa
            #binding.pry
          else
            nroMesa = pagPrueTod[28].text
          end

          arrCantNodos.each do |indexNodos|

            unless pagPrueTod[indexNodos] == nil

              unless pagPrueTod[indexNodos].attributes.values[0] == nil
                
                # p pagPrueTod[indexNodos].text
                # p pagPrueTod[indexNodos].attributes.values[0]


                if pagPrueTod[indexNodos].attributes.values[0].value == "colorborde_coldn" || \
                  pagPrueTod[indexNodos].attributes.values[0].value == "centrado" || \
                  pagPrueTod[indexNodos].attributes.values[0].value == "alaizquierda" || \
                  pagPrueTod[indexNodos].attributes.values[0].value == " colorborde_coldn" || \
                  pagPrueTod[indexNodos].attributes.values[0].value == "aladerecha" || \
                  pagPrueTod[indexNodos].attributes.values[0].value == ""

                  #p pagPrueTod[indexNodos].text

                  
                  if alternadorKeysVAlues.even?
                    partidoEnUso = pagPrueTod[indexNodos].text
                    hashResultados[partidoEnUso] = 0
                    #binding.pry
                  else
                    hashResultados[partidoEnUso] = pagPrueTod[indexNodos].text
                  end
                alternadorKeysVAlues = alternadorKeysVAlues + 1
                end
              end
            end
          end
          #binding.pry
          hashMesa = {nroMesa=> hashResultados}

          arrCircui<< hashMesa
        end

      end

      arrSeccion<< arrCircui

    end

    arrTodo <<arrSeccion

    #binding.pry
    #pagPrueTod[68].attributes.values[0].value == "alaizquierda"

  end
  
  serialized_array = Marshal.dump(arrTodo)

  File.open('resultados_Dipu.txt', 'wb') {|f| f.write(serialized_array) }


end


# task :pruebaImport => :environment do
#   School.all.each_with_index do |escue , index|
#     escue.name = 
#     escue.address = 
#     escue.lat = 
#     escue.lon =


#     escue.save!
#     end
#   end

# end


#  task :sumarEscuelas => :environment do



#   a = [345=>["pichi"=>4, "pachi" => 5, "pochi" => 6],346=> ["pichi"=>2, "pachi" => 10, "pochi" => 3],347=> ["pichi"=>4, "pachi" => 5, "pochi" => 6],348=> ["pichi"=>2, "pachi" => 10, "pochi" => 3]]
# rang = [[1,[345,346],[2[347,348]]

# rang.each do |ran|
#   ranExt =*(ran[1][0]..ran[1][1])

#   ranExt.each do |rangex|
#     votos = a[rangex].values.values
#     votos.each_with_index do |vo, inde|
#       resEscue[inde]= resEscue[inde] + vo
#     end
#     resTotales = []
#     resTotales << [[ran[0][0], ran[0][1]] =>resEscue]
#   end

#   serialized_array = Marshal.dump(arrSeccion)

#   File.open('escuelasYResultados.txt', 'wb') {|f| f.write(serialized_array) }


# end

