/******************************************************************************
Includes
******************************************************************************/
#include <string.h>
#include <LiquidCrystal.h>
#include <Keypad.h>
/******************************************************************************
LCD Setup Parameters
******************************************************************************/
const int C_LCD_PIN1 = 12;
const int C_LCD_PIN2 = 11;
const int C_LCD_PIN3 = 7;
const int C_LCD_PIN4 = 6;
const int C_LCD_PIN5 = 5;
const int C_LCD_PIN6 = 4;

LiquidCrystal m_lcdInstance(C_LCD_PIN1, C_LCD_PIN2, C_LCD_PIN3, C_LCD_PIN4, C_LCD_PIN5, C_LCD_PIN6);

/******************************************************************************
Keypad Setup Parameters
******************************************************************************/
const byte C_KEYPAD_ROWS = 4;
const byte C_KEYPAD_COLS = 4;

char T_KEYPAD_KEYS[C_KEYPAD_ROWS][C_KEYPAD_COLS] = {
  {'1', '2', '3', 'A'},
  {'4', '5', '6', 'B'},
  {'7', '8', '9', 'C'},
  {'*', '0', '#', 'D'}
};

const byte C_KEYPAD_ROW_PINS[C_KEYPAD_COLS] = {0, 1, 2, 3};
const byte C_KEYPAD_COL_PINS[C_KEYPAD_COLS] = {8, 9, 10, 13};

Keypad m_keypadInstance(makeKeymap(T_KEYPAD_KEYS), C_KEYPAD_ROW_PINS, C_KEYPAD_COL_PINS, C_KEYPAD_ROWS, C_KEYPAD_COLS);

/******************************************************************************
State Declaration Setup Parameters
******************************************************************************/
enum E_DEVICE_STATES{
  E_DEVICE_STATES_IDLE,
  E_DEVICE_STATES_START_MENU,
  E_DEVICE_STATES_LOGIN_MENU,
  E_DEVICE_STATES_CREATE_USER,
  E_DEVICE_STATES_DISPLAY_MENU,
  E_DEVICE_STATES_STATUS
};

E_DEVICE_STATES m_currentState;
E_DEVICE_STATES m_lastState;

/******************************************************************************
IR Sensor Setup Parameters
******************************************************************************/


/******************************************************************************
Misc. Parameters
******************************************************************************/
const int C_TIMEOUT_THRESHOLD = 10000;
int m_statusTimeoutCounter = 0;

/******************************************************************************
SETUP Code
******************************************************************************/
void setup() {
  // put your setup code here, to run once:

}

/******************************************************************************
LOOP Code
******************************************************************************/
void loop() {
  // put your main code here, to run repeatedly:
  determineCurrentState(false, 1);
}

/******************************************************************************
STATE TRANSITION Code
******************************************************************************/
void determineCurrentState(bool recentUserActivity, int userSelection) {
  E_DEVICE_STATES t_currentState = m_currentState;
  
  switch(m_currentState) {
    case E_DEVICE_STATES_IDLE:
      if (recentUserActivity) {
        m_currentState = E_DEVICE_STATES_START_MENU;
      }
      break;
    case E_DEVICE_STATES_START_MENU:
      if (!recentUserActivity) {
        m_currentState = E_DEVICE_STATES_STATUS;
      }
      else {
        switch(userSelection) {
          case 1:
            m_currentState = E_DEVICE_STATES_LOGIN_MENU;
            break;
          case 2:
            m_currentState = E_DEVICE_STATES_CREATE_USER;
            break;
          default:
            break;
        }
      }
      break;
    case E_DEVICE_STATES_LOGIN_MENU:
      if (!recentUserActivity) {
        m_currentState = E_DEVICE_STATES_STATUS;
      }
      else {
        switch(userSelection) {
          case 1:
            m_currentState = E_DEVICE_STATES_DISPLAY_MENU;
            break;
          case 2:
            m_currentState = E_DEVICE_STATES_START_MENU;
          default:
            break;
        }
      }
      break;
    case E_DEVICE_STATES_CREATE_USER:
      if (!recentUserActivity) {
        m_currentState = E_DEVICE_STATES_STATUS;
      }
      else {
        switch(userSelection) {
          case 1:
            m_currentState = E_DEVICE_STATES_LOGIN_MENU;
            break;
          case 2:
            m_currentState = E_DEVICE_STATES_START_MENU;
          default:
            break;
        }
      }
      break;
    case E_DEVICE_STATES_DISPLAY_MENU:
      if (!recentUserActivity) {
        m_currentState = E_DEVICE_STATES_STATUS;
      }
      else {
        switch(userSelection) {
          case 1:
            m_currentState = E_DEVICE_STATES_START_MENU;
            break;
          default:
            break;
        }
      }
      break;
    case E_DEVICE_STATES_STATUS:
      if (!recentUserActivity) {
        if (m_statusTimeoutCounter > C_TIMEOUT_THRESHOLD) {
          m_currentState = E_DEVICE_STATES_IDLE;
        }
        else { 
          m_statusTimeoutCounter += 1;
        }
      }
      else {
        m_statusTimeoutCounter = 0;
        m_currentState = m_lastState;
      }
    default:
      break;
  }

  if (t_currentState != m_currentState) {
    m_lastState = t_currentState;
  }
}

void exerciseCurrentState() {
  switch(m_currentState) {
    case E_DEVICE_STATES_IDLE:
      //TODO
      break;
    case E_DEVICE_STATES_START_MENU:
      //TODO
      break;
    case E_DEVICE_STATES_LOGIN_MENU:
      //TODO
      break;
    case E_DEVICE_STATES_CREATE_USER:
      //TODO
      break;
    case E_DEVICE_STATES_DISPLAY_MENU:
      //TODO
      break;
    case E_DEVICE_STATES_STATUS:
      //TODO
      break;
  }
}
/******************************************************************************
LCD Functions
******************************************************************************/

//TODO

/******************************************************************************
KEYPAD Functions
******************************************************************************/
char readKeypad() {
  char t_key = keypad.getKey();
  if (t_key != NO_KEY) {
    return t_key;
  }
  else {
    return null;
  }
}
  if (currentState == Idle_Menu && counter > 10) {
 currentState = processinput;
 counter = 1;
 writeScreen("Loading");
 }
  else if (currentState == Login_Menu && counter > 5) {
currentState = displaydata;
counter = 1;
writeScreen("Confirmation");
}
  else if (currentState == Display_Menu && counter > 10) {
 currentState = Idle;
 counter = 1;
 writeScreen("Success!!");
 }

  else {
 counter += 1;
 }
    
 switch(currentState) {
 case Idle:
 writeScreen(String(11 - counter) + " Loading...");
 break;
 case processinput:
  writeScreen(String(6 - counter) + " seconds to complete...");
 break;
 case displaydata:
 writeScreen(String(11 - counter) + " Success!!...");
 break; 
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


