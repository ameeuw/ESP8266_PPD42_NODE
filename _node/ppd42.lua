---------------------------------------------------------
-- module to read Shinyei PPD42 particulate matter sensor
--
-- Arne Meeuw <github.com/ameeuw>
--
---------------------------------------------------------

local PPD = {}

local partPin = 0
local startSample = 0
local ratio = 0
local lowpulseoccupancy = 0
local sampletime = 15000000
local callBackFunction = nil

PPD.values = {}

-- initialize timer for functionality like arduino's "pulseIn()"
function PPD.init(pin, sampletime)
  partPin = pin
  gpio.mode(partPin, gpio.INT)
end

-- ISR for falling edge trigger
function gotLOW(level)
  startLOW = tmr.now()
  gpio.trig(partPin, "up", gotHIGH)
end

-- ISR for rising edge trigger
function gotHIGH(level)
  duration = tmr.now()-startLOW
  lowpulseoccupancy = lowpulseoccupancy + duration
  --print((tmr.now() - startSample))
  if ( (tmr.now() - startSample) < sampletime ) then
    -- sampletime is not over -> start new reading
    gpio.mode(partPin, gpio.INT)
    gpio.trig(partPin, "down", gotLOW)
  else
    -- sampletime is over -> execute callBackFunction
    gpio.mode(partPin, gpio.INPUT) -- disable interrupt
    ratio = (lowpulseoccupancy / (tmr.now() - startSample)) * 100 -- calculate ratio
    
    callBackFunction(ratio)
    --print("Sampletime: "..(tmr.now() - startSample))
    --print("LPoccupancy: "..lowpulseoccupancy)
    --print("Ratio:"..ratio)
    --print("Concentration: "..convertRatio(ratio).." pcs/0.01cf")
  end
  --print(lowpulseoccupancy)
end

-- Read PPD42 value from selected pin
function PPD.readValue(callBack)
  callBackFunction = callBack
  lowpulseoccupancy = 0
  startSample = tmr.now()
  gpio.mode(partPin, gpio.INT)
  gpio.trig(partPin, "down", gotLOW)
end

function PPD.convertRatio(ratio)
  concentration = 1.1*ratio*ratio*ratio-3.8*ratio*ratio+520*ratio+0.62
  return concentration
end

-- expose module
return PPD