/*

*/
# include <string.h>
#include <LiquidCrystal.h>
#include "Keypad.h"

enum differentStates {
  
  Idle,
  processinput,
  displaydata
};

//Keypad setup
const byte ROWS = 4; // four rows
const byte COLS = 4; // three columns
char keys[ROWS][COLS] = {
  {'1','2','3' },
  {'4','5','6' },
  {'7','8','9' },
  {'*','0','#' }
};

byte rowPins[ROWS] = {0, 1, 2, 3};
byte colPins[COLS] = {8, 9, 10, 13};
Keypad keypad = Keypad( makeKeymap(keys), rowPins, colPins, ROWS, COLS );
char KEY[4] = {'1','2','3','4'}; // default secret key
char attempt[4] = {0,0,0,0};
int z=0;

differentStates currentState;
int counter;
LiquidCrystal lcd(12, 11, 7, 6, 5, 4);

// Logging people
int passwords[3] = {2, 5, 1};
int Selectedperson = 0;

void setup() {
    currentState = Idle;
    counter = 1;
    lcd.begin(16, 2); 
    Serial.begin(9600);
}

void loop() {
  delay(500);
  char key = keypad.getKey();
    
  if (key != NO_KEY) {
    lcd.print(key);
  }
  else{
    writeScreen("No key");
  }
    
//     if (currentState == Idle && counter > 10) {
//       currentState = processinput;
//       counter = 1;
//       writeScreen("Loading");
//     }
//     else if (currentState == processinput && counter > 5) {
//       currentState = displaydata;
//       counter = 1;
//       writeScreen("Confirmation");
//     }
//     else if (currentState == displaydata && counter > 10) {
//       currentState = Idle;
//       counter = 1;
//       writeScreen("Success!!");
// }

//     else {
//       counter += 1;
//     }
    
//     switch(currentState) {
//       case Idle:
//         writeScreen(String(11 - counter) + " Loading...");
//         break;
//       case processinput:
//         writeScreen(String(6 - counter) + " seconds to complete...");
//         break;
//       case displaydata:
//         writeScreen(String(11 - counter) + " Success!!...");
//         break; 
//     }
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

void correctKEY() {// do this if the correct KEY is entered 
  Serial.println(" KEY ACCEPTED...");
}

void incorrectKEY() {// do this if an incorrect KEY is entered
  Serial.println("KEY REJECTED!");
}

void checkKEY() {
  int correct=0;
  int i;
  for ( i = 0; i < 4 ; i++ ){
  if (attempt[i]==KEY[i]){
      correct++;
    }
  }
  if (correct==4){
    correctKEY();
  }
  else{
    incorrectKEY();
  }
  for (int zz=0; zz<4; zz++) {// clear previous key input
    attempt[zz]=0;
  }
}

void readKeypad() {
  char key = keypad.getKey();
  if (key != NO_KEY) {
    switch(key) {
      case '*':
        z=0;
        break;
      case '#':
        delay(100); // added debounce
        checkKEY();
        break;
      default:
        attempt[z]=key;
        z++;
      }
   }
}
