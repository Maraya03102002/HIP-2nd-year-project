/*

*/
# include <string.h>

enum differentStates {
  
  Idle,
  processinput,
  displaydata
};

differentStates currentState;
int counter;

void setup() {
    currentState = Idle;
    counter = 1;
    Serial.begin(9600);
}

void loop() {
    delay(500);
    if (currentState == Idle && counter > 10) {
      currentState = processinput;
      counter = 1;
      Serial.println("Loading");
    }
    else if (currentState == processinput && counter > 5) {
      currentState = displaydata;
      counter = 1;
      Serial.println("Confirmation");
    }
    else if (currentState == displaydata && counter > 10) {
      currentState = Idle;
      counter = 1;
      Serial.println("Success!!");
 }

    else {
      counter += 1;
    }
    
    switch(currentState) {
      case Idle:
        Serial.println(String(11 - counter) + " Loading...");
        break;
      case processinput:
        Serial.println(String(6 - counter) + " seconds to complete...");
        break;
      case displaydata:
        Serial.println(String(11 - counter) + " Success!!...");
        break; 
    }
}
