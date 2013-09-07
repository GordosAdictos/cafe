
require 'pry'
require 'geocoder'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require "rails"

class Hash
  def deep_dup
    Marshal.load(Marshal.dump(self))
  end
end


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

  serialized_array = Marshal.dump(escueNue)

  File.open('escuelas_nuevas_con_coord.txt', 'wb') {|f| f.write(serialized_array) }

  

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


 task :sumarEscuelas => :environment do

  escue = Marshal.load File.read("escuelas_nuevas_con_coord.txt")




  votos = Marshal.load File.read('resultados_Dipu.txt')

rangnum = 0
  conter = 0
  arrVotos = {}

  votos.each do |grup|
    grup.each do |hashi|
      hashi.each do |mini|

        #binding.pry
        arrVotos = mini.merge(arrVotos)
      end
    end
  end

  #escuelasAgrupadas = arrEscuelas .each_slice(7).to_a

 resEscue = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
 resTotales = []
 arrPart = []



  # a = [345=>["pichi"=>4, "pachi" => 5, "pochi" => 6],346=> ["pichi"=>2, "pachi" => 10, "pochi" => 3],347=> ["pichi"=>4, "pachi" => 5, "pochi" => 6],348=> ["pichi"=>2, "pachi" => 10, "pochi" => 3]]
  # rang = [[1,[345,346],[2[347,348]]
  resEscue[0] = 0
  escue.each do |ran|
    ranExt =*(ran[2]..ran[3])
      ranExt.each do |rangex|
        
        rangnum = rangex.to_i

        #binding.pry
      arrPart = arrVotos[rangex].values
       

      arrPart.each_with_index do |vo, indoo|
        


            resEscue[indoo]= resEscue[indoo] + vo.to_i
            #binding.pry

      end
      resTotales << [[ran[2], ran[3]] =>resEscue]
      binding.pry

      resEscue.deep_dup
    end

  end

    binding.pry

    serialized_array = Marshal.dump(arrSeccion)

    File.open('escuelasYResultados.txt', 'wb') {|f| f.write(serialized_array) }

end








# task :ponerDip => :environment do
#   School.all.each_with_index do |pol , index|
#     if index ==0
#       pol.name = "Diputados"
#     end
#     pol.save!
#   end
# end


 task :sumarEscuelas2 => :environment do


  escue = Marshal.load File.read("escuelas_nuevas_con_coord.txt")
  escue.each_with_index do |es , ind|
    es[7] = ind
  end



  votos = Marshal.load File.read('resultados_Dipu.txt')

  rangnum = 0
  conter = 0
  arrVotos = {}

  votos.each do |grup|
    grup.each do |hashi|
      hashi.each do |mini|

        #binding.pry
        arrVotos = mini.merge(arrVotos)
      end
    end
  end
  resEscue = []
  resTotales = []
  resVacio = []

 escue.each do |ran|
  resEscue = resVacio.dup
  ranExt =*(ran[2]..ran[3])
  ranExt.each do |rangex|
      
    rangnum = rangex.to_i

      #binding.pry
      
      if arrVotos[rangex] == nil
        p rangex
        #binding.pry
      else

      
        arrPart = arrVotos[rangex].values
         
        arrPart.each_with_index do |vo , ind|
            
            if resEscue[ind] == nil
              resEscue[ind] = 0
            end
            resEscue[ind] +=  vo.to_i
                    
          end
        end

      end
      
        resTotales.push [ran, resEscue]
        p resEscue
    #binding.pry

  end

  serialized_array = Marshal.dump(resTotales)

  File.open('Resultados.txt', 'wb') {|f| f.write(serialized_array) }
  binding.pry

end



 task :escuelas => :environment do

  resul = Marshal.load File.read('Resultados.txt')
  r = "para ver"
  cant = resul.count
  extendido = * (0..cant)
  ext = *(0..16)
  para_borrar = []

  extendido.each_with_index do |esc, ind|
    
    revisar = *(ind+1 ..cant-1)
    revisar.each do |sospech|
      if resul[esc][0][0] == resul[sospech][0][0] || resul[esc][0][1] == resul[sospech][0][1] 
        unless resul[sospech].count == 0 || resul[esc].count == 0
          p sospech
          p ind
          p "----------------"
          p resul[esc][0][0]
          p resul[sospech][0][0]
          p resul[esc][0][1]
          p resul[sospech][0][1]
          p "----------------"
          p resul[esc][1]
          ext.each_with_index do |nro , ind|
            resul[esc][1][ind] += resul[sospech][1][ind]
          end
          p resul[esc][1]
          p resul[esc][0][2] << "-"<< resul[sospech][0][2]
          p resul[esc] [0][3] << "-" << resul[sospech][0][3]
          para_borrar.push sospech
        end
      end
    end
  end
  para_borrar.each do |borr|
    resul.delete_at(borr)
  end

  binding.pry
  resul.each do  |re|
    a = School.new
    a.id = re[0][7]
    a.name = re[0][0]
    
    a.lat = re[0][5]
    a.lon = re[0][6]
    a.address = re[0][1]
    #a.group = r[0][2] + "..." + re[0][3]
#inding.pry
    p a.name
    a.save!
  end
end
