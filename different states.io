/*
*/
# include <string.h>
#include <LiquidCrystal.h>

enum differentStates {
  Intro,
  DisplayData,
  EnterPin
};

differentStates currentState;
int counter;

const int Buttonpress1 = 2;
const int Buttonpress2 = 3;
LiquidCrystal lcd(12, 11, 7, 6, 5, 4);
bool buttonpress1 = false;
bool buttonpress2 = false;


void setup() {
    currentState = Intro;
    counter = 1;
    pinMode(Buttonpress1, INPUT_PULLUP);
    pinMode(Buttonpress2, INPUT_PULLUP);
    
    attachInterrupt(digitalPinToInterrupt(Buttonpress1), interruptServiceRoutine1, RISING);
    attachInterrupt(digitalPinToInterrupt(Buttonpress2), interruptServiceRoutine2, RISING);
    Serial.begin(9600);
}

void loop() {
    delay(500);
    
    switch(currentState) {
      case Intro:
        if (buttonpress1) {
          Serial.println("Welcome!");
          buttonpress1 = false;
        }
        break;
      case DisplayData:
        if (buttonpress2) {
          Serial.println("Confirmation!");
          buttonpress2 = false;
        }        
        break; 
      case EnterPin:
        if (buttonpress2) {
          Serial.println("Enter Pin!");
          buttonpress2 = false;
        } 
    }
}

void interruptServiceRoutine1() {
    if (currentState == DisplayData) {
      currentState = EnterPin;
    }
    else {
      currentState = Intro;
    }
    counter = 1;
    buttonpress1 = true;
    delay(100);//100
    Serial.println("Button1 Pressed");
  
}
void interruptServiceRoutine2() {
    //currentState = DisplayData;
    if (currentState == DisplayData) {
      currentState = EnterPin;
    }
    else {
      currentState = DisplayData;
    }
    counter = 1;
    buttonpress2 = true;
    delay(100);//100
    Serial.println("Button2 Pressed");
}

    
