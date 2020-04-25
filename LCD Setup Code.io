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

const int C_LCD_ROWS = 2;
const int C_LCD_COLS = 16;

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
const int C_TIMEOUT_THRESHOLD = 100;
int m_statusTimeoutCounter = 0;

bool m_recentUserActivity = false;
int m_userSelection = 0;

char m_key[5] = {'1', '2', '2', '2', '3'};

/******************************************************************************
SETUP Code
******************************************************************************/
void setup() {
  // put your setup code here, to run once:
  m_lcdInstance.begin(C_LCD_COLS, C_LCD_ROWS);
  Serial.begin(9600);
  m_currentState = E_DEVICE_STATES_IDLE;
  
}

/******************************************************************************
LOOP Code
******************************************************************************/
void loop() {
  // put your main code here, to run repeatedly:
  determineCurrentState(m_recentUserActivity, m_userSelection);
  exerciseCurrentState();
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
          Serial.print("Welcome");
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
        Serial.print("");
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
      m_recentUserActivity = wakeup();
      break;
    case E_DEVICE_STATES_START_MENU:
      m_userSelection = 1;
      writeScreenString("Welcome!");
      break;
    case E_DEVICE_STATES_LOGIN_MENU:
      char* userInput = waitForKeypadInput(10000);
  
      if (userInput != NULL) {
        if(checkPasswordWrapper(userInput, m_key)) {
          m_userSelection = 1;
        }
        else {
          m_userSelection = 2;
          writeScreenString("Login Failed...");
        }
      }
      else {
        m_recentUserActivity = false;
        Serial.print("here");
      }
      break;
    case E_DEVICE_STATES_CREATE_USER:
      //TODO
      break;
    case E_DEVICE_STATES_DISPLAY_MENU:
      writeScreenString("Login Successful!");
      m_recentUserActivity = false;
      break;
    case E_DEVICE_STATES_STATUS:
      //TODO
      break;
  }
}
/******************************************************************************
LCD Functions
******************************************************************************/
void resetScreen(int wait) {
  for (int i = 0; i < C_LCD_ROWS; i++) {
    for (int j = 0; j < C_LCD_COLS; j++) {
      m_lcdInstance.setCursor(j, i);
      m_lcdInstance.print(" "); 
    }
  }
  delay(wait);
}

void writeScreenChar(char input[]) {
  if (sizeof(input) / sizeof(char) > C_LCD_COLS) {
    for (int i = 0; i < (sizeof(input) / sizeof(char)) - C_LCD_COLS; i++) {
      resetScreen(100);
      for (int j = 0; j < C_LCD_COLS; j++) {
        m_lcdInstance.setCursor(j, 1);
        m_lcdInstance.print(input[j + i]);
      }
      delay(500);
    }
  } 
  else {
    resetScreen(100);
    m_lcdInstance.setCursor(0, 1);
    m_lcdInstance.print(input);
    delay(1000);
  }
  resetScreen(100);
}

void writeScreenString(String input) {
  if (input.length() > C_LCD_COLS) {
    for (int i = 0; i < input.length() - C_LCD_COLS; i++) {
      resetScreen(100);
      for (int j = 0; j < C_LCD_COLS; j++) {
        m_lcdInstance.setCursor(j, 1);
        m_lcdInstance.print(input[j + i]);
      }
      delay(500);
    }
  } 
  else {
    resetScreen(100);
    m_lcdInstance.setCursor(0, 1);
    m_lcdInstance.print(input);
    delay(1000);
  }
}

/******************************************************************************
KEYPAD Functions
******************************************************************************/
bool wakeup() {
  if (readKeypad() != NULL) {
    return true;
  }
  else {
    return false;
  }
}

char* waitForKeypadInput(int timeout) {
  char t_lastKeyPress = NULL;
  char t_userInput[100];
  int t_userInputCount = 0;
  int t_elapsedSinceLastKeyPress = 0;
  while (t_lastKeyPress != '#' && t_elapsedSinceLastKeyPress < timeout) {
    t_lastKeyPress = readKeypad();
    if (t_lastKeyPress != NULL) {
      t_elapsedSinceLastKeyPress = 0;
      t_userInput[t_userInputCount] = t_lastKeyPress;
      t_userInputCount += 1;
      Serial.println("Earth");
    }
    else {
      t_elapsedSinceLastKeyPress += 1;
      delay(1);
      Serial.println("Air");
      
    }
  }
  
  if (t_elapsedSinceLastKeyPress == timeout && t_userInputCount == 0) {
    
    return NULL;
    
  }
  else {
    char t_output[t_userInputCount];
    
    for (int i = 0; i < t_userInputCount; i++) {
      t_output[i] = t_userInput[i];
    }
    
    return t_output;
  }
}

char readKeypad() {
  char t_key = m_keypadInstance.getKey();
  if (t_key != NO_KEY) {
    return t_key;
  }
  else {
    return NULL;
  }
}

void correctKey() {// do this if the correct KEY is entered 
  //Serial.println("KEY ACCEPTED...");
  writeScreenString("KEY ACCEPTED...");
}

void incorrectKey() {// do this if an incorrect KEY is entered
  //Serial.println("KEY REJECTED!");
  writeScreenString("KEY REJECTED!");
}

bool checkPassword(char input[], char key[]) {
  if (sizeof(input) == sizeof(key)) {
    for (int i = 0; i < sizeof(input) / sizeof(char); i++) {
      if (input[i] != key[i]) {
        return false;
      }
    }
    
    return true;
  }
  else {
    return false;
  }
}

bool checkPasswordWrapper(char input[], char key[]) {
  if(checkPassword(input, key)) {
    correctKey();
    return true;
  }
  else {
    incorrectKey();
    return false;
  }
}
