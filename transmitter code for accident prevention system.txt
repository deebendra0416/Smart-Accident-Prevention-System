#include <ESP8266WiFi.h>                                                    // esp8266 library
#include <espnow.h>
#define HOST "location-trackin-1564037843787.firebaseio.com"                          // the project name address from firebase id
#define AUTH "jXyWfDDX2BooHVcPPNlETJPuLLJOhLN0bhDyKKB5"            // the secret key generated from firebase
#define WIFI_SSID "Ramesh@123"                                             // input your home or public wifi name
#define WIFI_PASSWORD "12345678"                                    //password of wifi ssid
uint8_t broadcastAddress1[] = {0x2C, 0xF4, 0x32, 0x17, 0x31, 0xBC};
uint8_t broadcastAddress2[] = {0X98, 0XF4, 0XAB, 0XDC, 0X9E, 0XFA};
uint8_t broadcastAddress3[] = {0X98, 0XF4, 0XAB, 0XFB, 0X92, 0X91};
// Structure example to send data
// Must match the receiver structure
typedef struct {
  String VehicleNo1;
  String OwnerName1;
  String phoneNumber1;
  String VehicleType1;
  String CarryItems1;
  double latitude;
  double longitude;
  double tolatitude;
  double tolongitude;
} test_struct;

// Create a struct_message called test to store variables to be sent
unsigned long lastTime = 0;
  // send readings timer

// Callback when data is sent
void OnDataSent(uint8_t *mac_addr, uint8_t sendStatus) {
  Serial.print("Packet to:");
  snprintf(macStr, sizeof, "%02x:%02x:%02x:%02x:%02x:%02x",
           mac_addr, mac_add, mac_addr[3], mac_addr[5]);
  Serial.print(" send status: ");
  if (sendStatus == 0) {
    Serial.println("Delivery success");
  }
  else {
    Serial.println("Delivery fail");
  }
}
void setup() {

  Serial.begin(115200);
  delay(1000);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);                                     //try to connect with wifi
  Serial.print("Connecting to ");
  Serial.print(WIFI_SSID);
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }
  Serial.println();
  Serial.print("Connected to ");
  Serial.print("IP Address is : ");
  Serial.println(WiFi.localIP());                                            //print local IP address
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();
  // Init ESP-NOW
  if (esp_now_init() != 0) {
    Serial.println("Error initializing ESP-NOW");
    return;
  }

  esp_now_set_self_role(ESP_NOW_ROLE_CONTROLLER);

  // Once ESPNow is successfully Init, we will register for Send CB to
  // get the status of Trasnmitted packet
  esp_now_register_send_cb();

  // Register peer
  esp_now_add_peer(broadcastAddress1, ESP_NOW_ROLE_SLAVE, 1, NULL, 0);
  esp_now_add_peer(broadcastAddress2, ESP_NOW_ROLE_SLAVE, 1, NULL, 0);
}
void loop() {
  if ((millis() - lastTime) > timerDelay) {
    // Set values to send
    test.VehicleNo1   = "AS01BG7777";
    test.OwnerName1   = "ARUNKUMAR";
    test.phoneNumber1 = "8018456635";
    test.VehicleType1 = "Eicher";
    test.CarryItems1  = "Sugarcane";
    test.latitude  =  11.342423;
    test.longitude  = 77.728165;
    test.tolatitude  = 26.2006;
    test.tolongitude  = 92.9376;
    test.checklatitude1    = 11.5053;
  
    // Send message via ESP-NOW
    esp_now_send(0, (uint8_t *) &test, sizeof(test));

    lastTime = millis();
  }
}
