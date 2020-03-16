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
/*

*/

#include <LiquidCrystal.h>

//Constants
const int pResistor1 = A0; // Photoresistor at Arduino analog pin A0
const int pResistor2 = A1; 
int value1, value2;
LiquidCrystal lcd(12, 11, 7, 6, 5, 4);

// Logging people
String data[3] = {"Bob", "Helen", "Ning"};
int passwords[3] = {2, 5, 1};
int Selectedperson = 0;

void setup() {
  pinMode(pResistor1, INPUT);// Set pResistor - A0 pin as an input (optional)
  pinMode(pResistor2, INPUT);
  lcd.begin(16, 2);
  
  value1 = 0;
  value2 = 0;
  
  Serial.begin(9600);
}

int timeStamp1 = 0;
int timeStamp2 = 0;

int indexer = 0;

void loop() {
  

  if (analogRead(pResistor1) < 1020) {
    timeStamp1 = millis();
    if ((timeStamp1 - timeStamp2) < 10) {
      Serial.println("Moving Right!");
      indexer -= 1;
      if (indexer < 0) {
        indexer = 2;
      }
      Serial.println(data[indexer]);
      delay(1000);
    }
  } 
  if (analogRead(pResistor2) < 1020) {
    timeStamp2 = millis();
    if ((timeStamp2 - timeStamp1) < 10) {
      Serial.println("Moving Left!");
      indexer += 1;
      if (indexer > 2) {
        indexer = 0;
      }
      Serial.println(data[indexer]);
      delay(1000);
    }
  }
  writeScreen(data[indexer]);
}

boolean moveRight(int photoValue) {
  if (photoValue < 1020) {
    timeStamp1 = millis();
    
    if ((timeStamp1 - timeStamp2) < 10) {
      Serial.println("Moving Right!");
      delay(1000);
      
      return true;
    }
  }
  
  return false;
}

boolean moveLeft(int photoValue) {
  if (photoValue < 1020) {
    timeStamp2 = millis();
    if ((timeStamp2 - timeStamp1) < 10) {
      Serial.println("Moving Left!");
      delay(1000);
      
      return true;
    }
  }
  
  return false;
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
/*

*/
#include <string.h>
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
String data[3] = {"Bob", "Helen", "Ning"};
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
#include <string.h>
#include <LiquidCrystal.h>
#include <Keypad.h>

const byte KEYPAD_ROWS = 4;
const byte KEYPAD_COLS = 4;

char KEYS[KEYPAD_ROWS][KEYPAD_COLS] = {
	{'1', '2', '3', 'A'},
	{'4', '5', '6', 'B'},
	{'7', '8', '9', 'C'},
	{'*', '0', '#', 'D'} 
};

byte rowsPins[KEYPAD_ROWS] = {0, 1, 2, 3};
byte colsPins[KEYPAD_COLS] = {8, 9, 10, 13};

enum E_STATES{
	E_STATES_IDLE,
	E_STATES_PROCESS,
	E_STATES_DISPLAY
}; 

E_STATES current_state;

const byte LCD_ROWS = 2;
const byte LCD_COLS = 16;

LiquidCrystal lcd(12, 11, 7, 6, 5, 4);
Keypad keypad(makeKeymap(KEYS), rowsPins, colsPins, KEYPAD_ROWS, KEYPAD_COLS);

void setup() {
	lcd.begin(16, 2);
	Serial.begin(9600);
}

int counter = 0;

void loop() {
	//readKeypad();
	keypadDeletingSystem();
}

void readKeypad() {
	char key = keypad.getKey();
	if (key != NO_KEY) {
	  counter += 1;
		writeCharScreen(key);
    Serial.println(key);
    Serial.println(counter);
	}
}

void resetScreen() {
	for (int i = 0; i < LCD_ROWS; i++) {
		lcd.setCursor(0, i);
		lcd.print("                ");
	}
}

void writeStringScreen(String input) {
	if (input.length() > LCD_COLS) {
		for (int i = 0; i < input.length() - LCD_COLS; i++) {
			resetScreen();
			
			for (int j = 0; j < LCD_COLS; j++) {
				lcd.setCursor(j, LCD_ROWS);
				lcd.print(input[j + i]);
			}
		}
		delay(1000);
	}
	else {
		resetScreen();
		lcd.setCursor(0, 1);
		//lcd.print(input);
		char blah[5] = {'E', 'N', 'T', 'E', 'R'};
		lcd.setCursor(0, 0);
		lcd.print(blah);
		delay(1000);
	}
	resetScreen();
}

void writeCharScreen(char input) {
	resetScreen();
	lcd.setCursor(0, LCD_ROWS);
	lcd.print(input);
	delay(500);
	resetScreen();
}

void keypadDeletingSystem() {
  int index = 0;
  char input[LCD_COLS] = {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '};
  while(true) {
    char key = keypad.getKey();
    if (key != NO_KEY) {
      Serial.println(key);
      switch(key) {
        case '#':
        
        return;
        break;
        case 'A':
        if (index >= 0) {
          input[index] = ' ';
          index -= 1;
        }
        if (index < 0) {
          index = 0;
        }
        break;
        default:
        Serial.println("I'm here!");
        if (index < LCD_COLS) {
          input[index] = key;
          index += 1;
        } 
        else {
          input[index] = key;
        }
        break;
      };
      Serial.println(input);
      resetScreen();
      for (int i = 0; i <= index; i++) {
  	    lcd.setCursor(i, LCD_ROWS);
		    lcd.print(input[i]);  
      }
    }
  }
}
  
    

  
  



    

