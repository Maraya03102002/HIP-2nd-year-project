/*

*/
#include <string.h>
#include <LiquidCrystal.h>

enum differentstates{
  Idle,
  processinput,
  displaydata
};

differentstates currentstates;

int counter;
const int Button1= 2;
const int Button2= 3;
LiquidCrystal lcd(12, 11, 7, 6, 5, 4);


String data[3] = {"Bob", "Helen", "Ning"};
int passwords[3] = {2, 5, 1};
int Selectedperson = 0;
int Buttonpresses; //To determine how many time the button will be pressed
bool buttonpress = false;
bool buttonpress2 = false;
  

void setup() {
   lcd.begin(16, 2); 
    currentstates=Idle;
    counter= 0;
    Serial.begin(9600);
    
    Buttonpresses=0;
    
  pinMode(Button1,INPUT_PULLUP);
  
  pinMode(Button2, INPUT_PULLUP); 
  
  attachInterrupt(digitalPinToInterrupt(Button1), interruptServiceRoutine1, FALLING);
  attachInterrupt(digitalPinToInterrupt(Button2), interruptServiceRoutine2, FALLING);
  
    
}

void loop() {
  delay(1);
  switch(currentstates) {
    case Idle:
      if (buttonpress) {
        currentstates = processinput;
        counter = 0;
        buttonpress = false;
        Serial.println("Waking up");
      }
      break;
    case processinput:
      if (counter > 10000) {
        currentstates = Idle;
        counter = 0;
        Serial.println("Hibernating");
      }
      
      if (buttonpress) {
        currentstates = displaydata;
        counter = 0;
        Selectedperson = Buttonpresses;
        Buttonpresses = 0;
        buttonpress = false;
        Serial.println("Confirmation");
      }
      if (buttonpress2) {
        counter = 0;
        //Serial.println("Item contains " + String(data[Buttonpresses]));
        writeScreen(data[Buttonpresses]);
        buttonpress2 = false;
      }
      break;
    case displaydata:
      if (buttonpress || counter > 10000) {
        currentstates = Idle;
        counter = 0;
        buttonpress = false;
        if (Buttonpresses == passwords[Selectedperson]) {
          Serial.println("Success! " + data[Selectedperson] + " is logged in!");

          String blah1 = "Success! " + data[Selectedperson] + " is logged in!";
          writeScreen(blah1);
          writeScreen(blah1);
        } 
        else {
          
          String blah2 = "Failure! " + data[Selectedperson] + " is not logged in!";
          writeScreen(blah2);
          
          Serial.println("Failure! " + data[Selectedperson] + " is not logged in!");
          Serial.println(String(Buttonpresses) + " was pressed, expected " + String(passwords[Selectedperson]));
        }
      }
      break;
  }
  
  counter += 1;
}

void interruptServiceRoutine1() {
     buttonpress=true;
     delay(100);
}
void interruptServiceRoutine2() {
  if (currentstates == processinput) {
    buttonpress2 = true;
    Buttonpresses += 1;
    
    if (Buttonpresses > 2) {
      Buttonpresses = 0;
    }
    Serial.println("Item contains " + String(data[Buttonpresses]));
    delay(100);
  }
  else if (currentstates == displaydata) {
    Buttonpresses += 1;
    
    if (Buttonpresses > 9) {
      Buttonpresses = 0;
    }
  }
} 

void resetScreen() {
  lcd.setCursor(0, 0);
  lcd.print("                ");
  lcd.setCursor(0, 1);
  lcd.print("                ");
  delay(100);
}

void writeScreen(String input) {
  int row = 1;
  int widthLCD = 16;
  
  if (input.length() > widthLCD) {
    for (int i = 0; i < input.length() - widthLCD; i++) {
      resetScreen();
      for (int j = 0; j < widthLCD; j++) {
        lcd.setCursor(j, row);
        lcd.print(input[j + i]);
      }
      delay(500);
    }
  } 
  else {
    resetScreen();
    lcd.setCursor(0, row);
    lcd.print(input);
    delay(1000);
  }
  resetScreen();
}

