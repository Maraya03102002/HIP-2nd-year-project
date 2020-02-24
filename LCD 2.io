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
  
