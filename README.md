# ESP8266_PPD42_NODE
WiFi enabled node utilizing Shinyei PPD42 sensor to measure particulate matter values.

The sources for this sensor are twofold:

(1) The code for the node is written as scripts for the ESP8266 nodeMCU Lua interpreting firmware and is installed after flashing the chip with the according version (atm 0.9.5).

(2) The webserver code consists of a scipt offering a REST API for the node to publish its sensor data and a graphing frontend that delivers a optical representation of the history of the recorded values.