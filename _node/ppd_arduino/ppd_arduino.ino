/*
 *  This sketch reads values from PPD42 sensor and sends data via HTTP GET requests to m-e-e-u-w.de/ppd/putData.php service.
 *
 */
 
#include <ESP8266WiFi.h>

// Sensor config
const char* sensorID = "s1";

// WiFi config
const char* ssid = "TUM_CREATE";
const char* password = "tumcr34t3";

// Host config
const char* host = "m-e-e-u-w.de";

// Sensor variables
int part_input = 5;
unsigned long duration;
unsigned long starttime;
unsigned long sampletime_ms = 30000;//sampe 30s ;
unsigned long lowpulseoccupancy = 0;
float ratio = 0;
float concentration = 0;
float prev_concentration = 0;

void setup() 
{
  Serial.begin(115200);
  delay(10);
  // We start by connecting to a WiFi network
  
  Serial.println();
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);
  
  WiFi.begin(ssid, password);
  
  while (WiFi.status() != WL_CONNECTED) 
  {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");  
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());

  pinMode(part_input, INPUT);
}

int value = 0;

void loop() 
{
  concentration = readPPD();
  
  // Upload data only if new value is available
  if (concentration != prev_concentration)
  {
    sendData();
    prev_concentration = concentration;
  }
  else
  {
    
  }
}

void sendData()
{
  Serial.print("connecting to ");
  Serial.println(host);

  // Use WiFiClient class to create TCP connections
  WiFiClient client;
  const int httpPort = 80;
  if (!client.connect(host, httpPort)) 
  {
    Serial.println("connection failed");
    return;
  }

  // We now create a URI for the request
  String url = "/ppd/putData.php";
  url += "?s=";
  url += sensorID;
  url += "&v=";
  url += String(concentration);

  Serial.print("Requesting URL: ");
  Serial.println(url);

  // This will send the request to the server
  client.print(String("GET ") + url + " HTTP/1.1\r\n" +
       "Host: " + host + "\r\n" + 
       "Connection: close\r\n\r\n");
  delay(10);

  // Read all the lines of the reply from server and print them to Serial
  while(client.available())
  {
    String line = client.readStringUntil('\r');
    Serial.print(line);
  }

  Serial.println();
  Serial.println("closing connection");
}

double readPPD()
{    
  duration = pulseIn(part_input, LOW);
  Serial.print("PulseIn Value:");
  Serial.println(duration);
  lowpulseoccupancy = lowpulseoccupancy+duration;

  if ((millis()-starttime) > sampletime_ms)//if the sample time == 30s
  {
    ratio = lowpulseoccupancy/(sampletime_ms*10.0);  // Integer percentage 0=>100
//    concentration = 1.1*powf(ratio,3)-3.8*powf(ratio,2)+520*ratio+0.62; // using datasheet curve
    concentration = 1.1*ratio*ratio*ratio-3.8*ratio*ratio+520*ratio+0.62; // using datasheet curve
    lowpulseoccupancy = 0;
    starttime = millis();
  }
  
  double ppm = double(concentration);
  return ppm;
}
