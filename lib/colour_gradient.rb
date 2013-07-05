class ColourGradient

  def initialize(minNum, maxNum, color_from, color_to)
    #@gradients = nil;
    setNumberRange(minNum, maxNum)
    #@colours = [color_from, color_to];
    @startColour = color_from;
    @endColour = color_to; 
    #setColours(colours);
  end
  

  def setGradient(colourStart, colourEnd)
    @startColour = colourStart
    @endColour = colourEnd
  end

  def setNumberRange(minNumber, maxNumber)
    if maxNumber.to_i > minNumber.to_i
      @minNum = minNumber.to_i;
      @maxNum = maxNumber.to_i;
    else
      raise 'maxNumber (' + maxNumber.to_s + ') is not greater than minNumber (' + minNumber.to_s + ')'
    end
  end

  def colour_at(number)
    calcHex(number, @startColour[0..1], @endColour[0..1]) + calcHex(number, @startColour[2..3], @endColour[2..3]) + calcHex(number, @startColour[4..5], @endColour[4..5])
  end
  
  def kml_colour_at(number, alfa = "ff")
    color = colour_at(number)
    color = alfa + color[4..5] + color[2..3] + color[0..1]
    color
  end

  def calcHex(number, channelStart_Base16, channelEnd_Base16)
    num = number;
    if num < @minNum
      num = @minNum
    end
    if num > @maxNum
      num = @maxNum
    end
    numRange = @maxNum - @minNum;
    cStart_Base10 = channelStart_Base16.to_i(16)
    cEnd_Base10 = channelEnd_Base16.to_i(16)
    cPerUnit = (cEnd_Base10 - cStart_Base10)/numRange;
    c_Base10 = (cPerUnit * (num - @minNum) + cStart_Base10).round.abs
    return formatHex(c_Base10.to_s(16));
  end

  def formatHex(hex) 
    if hex.length == 1
      return '0' + hex;
    else
      return hex;
    end
  end
end