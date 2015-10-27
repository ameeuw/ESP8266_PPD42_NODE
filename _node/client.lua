-- ESP8266 PPD42 sensor node
ppdSensor = require("ppd42")

-- Start configuration server.
function startConfig()
     print('Config -> start webserver')
     print(node.heap())
     file.remove("init.lua")
     file.open("init.lua", "a+")
     file.writeline('dofile("config.lc")')
     file.close()
     tmr.delay(100000)
     node.restart()
end


-- read PPD42 sensor data
function ppd42read()
  print("Start reading...")
  ppdSensor.readValue(callBack)
end

function callBack(ratio)
  --print("Ratio:"..ratio)
  local concentration = ppdSensor.convertRatio(ratio)
  sendData("s1",concentration)
end

-- Connect to set server (to be replaced with mqtt, REST-call or similar)


-- GET request code to PHP-Script
function sendData(sensor, value)
	if sensor~=nil and value~=nil then
		get = "/ppd/putData.php?s=" .. sensor .. "&v=" .. value
	end	
	--print(get)
	conn=net.createConnection(net.TCP, 0)
     conn:dns(host, function(conn, ip) 
								if ip~=nil then
									--print("Connecting to "..ip..":"..port)
									conn:connect(port, ip)
								end
							end)
    conn:on("connection", function(sck) 
      print("Connected, sending value...")
      conn:send("GET "..get.." HTTP/1.1\r\nHost: "..host.."\r\n".."Connection: close\r\n\r\n")
      blink(pinG,3, 250)
      ppd42read()
      end)

    --conn:on("receive", function(sck, payload)
      --print(payload)
    --end)
end


-- Blink LED for status feedback
function blink(pin, times, delay)	
	local lighton=0
	local count=0
	tmr.alarm(0,delay,1,
		function()
			if lighton==0 then 
				lighton=1 
				pwm.setduty(pin, 512)
			else 
				lighton=0
				pwm.setduty(pin, 0)
			end
			if count==(times*2-1) then 
				tmr.stop(0) 
			else		
				count=count+1
			end
		end)
end


-- Check if button is pressed for a longer time
function checkLongPress()
    gpio.mode(pinReset,gpio.OUTPUT)
	gpio.write(pinReset,gpio.HIGH)
	tmr.alarm(1,500,0,function()
		if gpio.read(pinReset)~=gpio.HIGH then
			startConfig()
		else
			gpio.mode(pinReset,gpio.INT,gpio.PULLUP)
			gpio.trig(pinReset,"low",checkLongPress)
		end
	end)
end


if file.open('settings.lua', 'r') then 
  dofile('settings.lua')
	wifi.setmode(wifi.STATION)
	wifi.sta.config(network, password)
	wifi.sta.autoconnect(1)
	tmr.delay(100000)
	 
	pinReset=3
  ppdPin = 2
  pinR = 8
  pinG = 6
  pinB = 7
  
  gpio.mode(pinReset,gpio.INT,gpio.PULLUP)
  gpio.trig(pinReset,"low",checkLongPress)
  pwm.setup(pinR,300,0)
  pwm.setup(pinG,300,0)
  pwm.setup(pinB,300,0)
  pwm.start(pinR)
  pwm.start(pinG)
  pwm.start(pinB)
  
  ppdSensor.init(ppdPin)
  ppd42read()
else
  startConfig()
end
