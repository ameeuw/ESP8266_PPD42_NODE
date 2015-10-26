---------------------------------------------------------
-- module to read Shinyei PPD42 particulate matter sensor
--
-- Arne Meeuw <github.com/ameeuw>
--
---------------------------------------------------------

local PPD = {}
PPD.values = {}

-- initialize timer for functionality like arduino's "pulseIn()"
function PPD.init(pin)
  gpio.mode(pin, gpio.INT)
end

-- Read PPD42 value from selected pin
function PPD.readValue(pin)
  
end

-- expose module
return PPD