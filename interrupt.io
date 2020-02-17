#define interruptPin 2
#define ledPin 13

/*
Enumeration: arduinoState
Usage: The Arduino is either idle or active  
*/
enum arduinoState {
  idle,
  active 
};

// This global variable keeps track of the Arduino state
arduinoState m_arduinoState;
int m_activeCounter;

void setup() {
  // This sets up the interrupt pin
  pinMode(interruptPin, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(interruptPin), interruptServiceRoutine, FALLING);

  // This sets up the internal LED pin
  pinMode(ledPin, OUTPUT);
  
  // This initializes the Arduino state
  m_arduinoState = idle;

  // This initializes the active counter
  m_activeCounter = 0;
}

void loop() {
  switch(m_arduinoState) {
    case idle:
      // Do not blink LED
      break;
    case active:
      // Do blink LED
      if (m_activeCounter > 100) {
        // Reset counter
        m_activeCounter = 0;
        // Switch Arduino state to idle
        m_arduinoState = idle; 
      }
      else {
        m_activeCounter += 1;
        blinkLED();
      }
      break;    
  }
}
/* 
Function Name: interruptServiceRoutine()
Usage: This enables you to interrupt the loop() function to do something when an event occurs.
In this case, we use this to toggle the state of the Arduino from idle -> active or active -> idle when a button press occurs
*/
void interruptServiceRoutine() {
  // Reset counter
  m_activeCounter = 0;
  switch(m_arduinoState) {
    case idle:
      m_arduinoState = active;
      break;
    case active:
      m_arduinoState = idle;
      break;
  }
}

/* 
Function Name: blinkLED()
Usage: This 'blinks' the LED, turning it on, then off
*/
void blinkLED() {
  digitalWrite(ledPin, HIGH);
  delay(250);
  digitalWrite(ledPin, LOW);
  delay(250);
}

