/* Including the SoftwareSerial library for Bluetooth communication */
#include <SoftwareSerial.h>

// Pin definitions
const int leftLedPin = 2;
const int rightLedPin = 3;
//const int leftVibPin = 2;
//const int rightVibPin = 3;
const int rxPin = 9; // MUST Connect to TX on the Bluetooth module
const int txPin = 8; // MUST Connect to RX on the Bluetooth module
const int baudrate = 9600;

// Defining commands 
#define LEFT  'L' 
#define RIGHT 'R' 
#define STOP  'S'  

// Initialize the SoftwareSerial for Bluetooth communication
SoftwareSerial hc05(rxPin, txPin);

// Setup function
void setup() {
  // Set pin modes
  pinMode(leftLedPin, OUTPUT);
  pinMode(rightLedPin, OUTPUT);
  pinMode(rxPin, INPUT);
  pinMode(txPin, OUTPUT);

  // Initialize serial communication for debugging
  Serial.begin(9600);

  // Initialize Bluetooth communication
  hc05.begin(baudrate);

  // Check if Bluetooth module is connected
  if (hc05.isListening()) {
    Serial.println("Bluetooth module connected.");
  } else {
    Serial.println("Error: Bluetooth module not connected. Check wiring.");
  }
}

// Main loop function
void loop() {
  // Check if data is available from Bluetooth module
  if (hc05.available()) {
    // Read the received command
    char command = hc05.read();
    Serial.println(command);

    // Process the command
    switch (command) {
      case LEFT:
        digitalWrite(leftLedPin, HIGH);
        digitalWrite(rightLedPin, LOW);
        hc05.write("Left LED is on.\n");
        delay(100);
        digitalWrite(leftLedPin, LOW);
        break;

      case RIGHT:
        digitalWrite(rightLedPin, HIGH);
        digitalWrite(leftLedPin, LOW);
        delay(100);
        digitalWrite(rightLedPin, LOW);
        hc05.write("Right LED is on.\n");
        break;

      case STOP:
        digitalWrite(rightLedPin, LOW);
        digitalWrite(leftLedPin, LOW);
        hc05.write("Both LEDs are off.\n");
        break;

      default:
        hc05.write(command);
        break;
    }
  }
}
