/**
 * ESP32 Smart Collar - Alpha Tech
 * Hardware polling implementation for pet collar control
 */

#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

// Configuration
const char* ssid = "YOUR_WIFI_NAME";     // Change to your WiFi name
const char* password = "YOUR_WIFI_PASSWORD";   // Change to your WiFi password
const char* apiUrl = "https://executive-cent-reliability-eva.trycloudflare.com";
const char* locationApiUrl = "https://pacific-fighter-missile-stuffed.trycloudflare.com";
const char* collarId = "PET_001";  // Hardware collar identifier
const char* petId = "3c5387e8-cb87-4fc7-8e18-0fe44adc9519";  // Joel's pet ID

// Hardware pins
const int buzzerPin = 2;
const int ledPin = 4;
const int statusLedPin = 5;

// Timing configuration
const unsigned long pollingInterval = 5000;  // 5 seconds
const unsigned long commandDuration = 3000;  // 3 seconds buzzer/LED
const unsigned long wifiTimeout = 10000;     // 10 seconds WiFi timeout

// State variables
unsigned long lastPollTime = 0;
bool isExecutingCommand = false;
bool wifiConnected = false;

void setup() {
  Serial.begin(115200);
  Serial.println("🐕 Alpha Tech Smart Collar Starting...");
  
  // Initialize hardware
  pinMode(buzzerPin, OUTPUT);
  pinMode(ledPin, OUTPUT);
  pinMode(statusLedPin, OUTPUT);
  
  // Initial LED test
  testHardware();
  
  // Connect to WiFi
  connectToWiFi();
  
  Serial.println("✅ Collar initialized successfully");
  Serial.printf("📡 Collar ID: %s\n", collarId);
  Serial.printf("🐕 Pet ID: %s\n", petId);
  Serial.printf("🌐 API URL: %s\n", apiUrl);
}

void loop() {
  // Check WiFi connection
  if (WiFi.status() != WL_CONNECTED) {
    wifiConnected = false;
    digitalWrite(statusLedPin, LOW);
    connectToWiFi();
    return;
  }
  
  wifiConnected = true;
  digitalWrite(statusLedPin, HIGH);
  
  // Poll for commands every 5 seconds
  if (millis() - lastPollTime >= pollingInterval && !isExecutingCommand) {
    checkForCommands();
    lastPollTime = millis();
  }
  
  delay(100); // Small delay to prevent watchdog issues
}

void connectToWiFi() {
  Serial.println("🔄 Connecting to WiFi...");
  WiFi.begin(ssid, password);
  
  unsigned long startTime = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - startTime < wifiTimeout) {
    delay(500);
    Serial.print(".");
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println();
    Serial.printf("✅ WiFi connected! IP: %s\n", WiFi.localIP().toString().c_str());
    wifiConnected = true;
  } else {
    Serial.println();
    Serial.println("❌ WiFi connection failed. Retrying...");
    wifiConnected = false;
  }
}

void checkForCommands() {
  if (!wifiConnected) return;
  
  HTTPClient http;
  String url = String(apiUrl) + "/commands/" + String(petId);
  
  Serial.printf("📡 Polling: %s\n", url.c_str());
  
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  
  int httpResponseCode = http.GET();
  
  if (httpResponseCode == 200) {
    String response = http.getString();
    Serial.printf("📨 Response: %s\n", response.c_str());
    
    // Parse JSON response
    DynamicJsonDocument doc(1024);
    deserializeJson(doc, response);
    
    String command = doc["command"];
    
    if (command == "FIND_PET") {
      Serial.println("🚨 FIND_PET command received!");
      executeCommand();
    } else {
      Serial.println("⏳ No pending commands");
    }
  } else {
    Serial.printf("❌ HTTP Error: %d\n", httpResponseCode);
  }
  
  http.end();
}

void executeCommand() {
  isExecutingCommand = true;
  
  Serial.println("🔊 Activating buzzer and LEDs...");
  
  // Send immediate location update
  sendLocationUpdate();
  
  // Activate buzzer and LED for specified duration
  unsigned long startTime = millis();
  while (millis() - startTime < commandDuration) {
    // Buzzer pattern: 200ms on, 200ms off
    if ((millis() - startTime) % 400 < 200) {
      digitalWrite(buzzerPin, HIGH);
      digitalWrite(ledPin, HIGH);
    } else {
      digitalWrite(buzzerPin, LOW);
      digitalWrite(ledPin, LOW);
    }
    delay(50);
  }
  
  // Ensure everything is off
  digitalWrite(buzzerPin, LOW);
  digitalWrite(ledPin, LOW);
  
  Serial.println("✅ Command execution completed");
  
  // Send acknowledgment to backend
  sendAcknowledgment();
  
  isExecutingCommand = false;
}

void sendAcknowledgment() {
  if (!wifiConnected) return;
  
  HTTPClient http;
  String url = String(apiUrl) + "/commands/ack";
  
  Serial.printf("📤 Sending ACK to: %s\n", url.c_str());
  
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  
  // Create JSON payload
  DynamicJsonDocument doc(1024);
  doc["petId"] = petId;
  doc["status"] = "ACK_RECEIVED";
  
  String jsonString;
  serializeJson(doc, jsonString);
  
  int httpResponseCode = http.POST(jsonString);
  
  if (httpResponseCode == 200) {
    Serial.println("✅ Acknowledgment sent successfully");
  } else {
    Serial.printf("❌ ACK Error: %d\n", httpResponseCode);
  }
  
  http.end();
}

void sendLocationUpdate() {
  if (!wifiConnected) return;
  
  HTTPClient http;
  String url = String(locationApiUrl) + "/location/collar/" + String(collarId) + "/position";
  
  Serial.printf("📍 Sending location to: %s\n", url.c_str());
  
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  
  // Simulate GPS coordinates (Medellín area)
  float latitude = 6.2500 + (random(-100, 100) / 10000.0);
  float longitude = -75.5900 + (random(-100, 100) / 10000.0);
  
  // Create JSON payload
  DynamicJsonDocument doc(1024);
  doc["collarId"] = collarId;
  doc["petId"] = petId;
  doc["latitude"] = latitude;
  doc["longitude"] = longitude;
  doc["accuracy"] = random(5, 15);
  doc["timestamp"] = "2025-12-16T01:00:00.000Z"; // Real timestamp would need RTC
  
  String jsonString;
  serializeJson(doc, jsonString);
  
  int httpResponseCode = http.POST(jsonString);
  
  if (httpResponseCode == 200 || httpResponseCode == 201) {
    Serial.printf("📍 Location sent: %.4f, %.4f\n", latitude, longitude);
  } else {
    Serial.printf("❌ Location Error: %d\n", httpResponseCode);
  }
  
  http.end();
}

void testHardware() {
  Serial.println("🧪 Testing hardware...");
  
  // Test LEDs
  digitalWrite(ledPin, HIGH);
  digitalWrite(statusLedPin, HIGH);
  delay(500);
  digitalWrite(ledPin, LOW);
  digitalWrite(statusLedPin, LOW);
  
  // Test buzzer
  digitalWrite(buzzerPin, HIGH);
  delay(200);
  digitalWrite(buzzerPin, LOW);
  
  Serial.println("✅ Hardware test completed");
}