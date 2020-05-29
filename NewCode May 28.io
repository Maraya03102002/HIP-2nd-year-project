/******************************************************************************
  Includes
******************************************************************************/
#include <string.h>

#define HARDWARE_ENABLED

#ifdef HARDWARE_ENABLED
#include <LiquidCrystal.h>
#include <Keypad.h>
#endif

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

#ifdef HARDWARE_ENABLED
LiquidCrystal m_lcdInstance(C_LCD_PIN1, C_LCD_PIN2, C_LCD_PIN3, C_LCD_PIN4, C_LCD_PIN5, C_LCD_PIN6);
#endif

/******************************************************************************
  Keypad Setup Parameters
******************************************************************************/
#ifdef HARDWARE_ENABLED
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
#endif

/******************************************************************************
  State Declaration Setup Parameters
******************************************************************************/
enum E_DEVICE_STATES {
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
  Structures
******************************************************************************/

/******************************************************************************
  Misc. Parameters
******************************************************************************/
const int C_TIMEOUT_THRESHOLD = 10;
int m_statusTimeoutCounter = 0;

bool m_recentUserActivity = false;
int m_userSelection = 0;

String m_key = "22222";

String m_keys[] = {"22222", "12345", "13579", "24680"};

String m_users[] = {"maraya", "elyse", "justin", "anthony"};

/******************************************************************************
  SETUP Code
******************************************************************************/
void setup() {
  // put your setup code here, to run once:
#ifdef HARDWARE_ENABLED
  m_lcdInstance.begin(C_LCD_COLS, C_LCD_ROWS);
#endif
  m_currentState = E_DEVICE_STATES_IDLE;
  Serial.begin(9600);
  Serial.println("Initializing...");
}

/******************************************************************************
  LOOP Code
******************************************************************************/
void loop() {
  // put your main code here, to run repeatedly:
  determineCurrentState(m_recentUserActivity, m_userSelection);
  //String Input= waitForKeypadInput(10000);
  //Serial.print(Input);
  //String lol = readKeypad();
  //if (lol != "") { Serial.println(lol); }
  // exerciseCurrentState();
  delay(1000);
}

/******************************************************************************
  STATE TRANSITION Code
******************************************************************************/
void determineCurrentState(bool recentUserActivity, int userSelection) {
  E_DEVICE_STATES t_currentState = m_currentState;

  switch (m_currentState) {
    case E_DEVICE_STATES_IDLE:
      executeIdleState(recentUserActivity);
      break;
    case E_DEVICE_STATES_START_MENU:
      executeStartMenuState(recentUserActivity);
      break;
    case E_DEVICE_STATES_LOGIN_MENU:
      executeLoginMenuState(recentUserActivity);
      break;
    case E_DEVICE_STATES_CREATE_USER:
      executeCreateUserState(recentUserActivity);
      break;
    case E_DEVICE_STATES_DISPLAY_MENU:
      executeDisplayMenuState(recentUserActivity);
      break;
    case E_DEVICE_STATES_STATUS:
      executeStatusState(recentUserActivity);
      break;
    default:
      break;
  }

  if (t_currentState != m_currentState) {
    m_lastState = t_currentState;
  }
}

/******************************************************************************
  Execute Current State Functions
******************************************************************************/
void executeIdleState(bool recentUserActivity) {
  //Serial.println("IDLE...");
  writeScreenString ("Hello!!");
  if (recentUserActivity) {
    m_currentState = E_DEVICE_STATES_START_MENU;
  }
  else {
    m_recentUserActivity = exitIdleMode();
  }
}

void executeStartMenuState(bool recentUserActivity) {
  Serial.println("Start menu...");
  String readKey = "";

  if (!recentUserActivity) {
    m_currentState = E_DEVICE_STATES_STATUS;
  }
  else {
   readKey = readKeypad();
  
    Serial.println(readKey);
    if (readKey == "") { //need to add some timeout
    Serial.println("Readkey was empty");
      m_recentUserActivity = true;
     // Serial.println("Graduation");
    }
    else {

        if (readKey == "8") {
          Serial.println("Going to login menu");
          m_currentState = E_DEVICE_STATES_LOGIN_MENU;
        }
        else if (readKey == "9") {
          Serial.println("Going to create user");
          m_currentState = E_DEVICE_STATES_CREATE_USER;
        
        }
        else {
          Serial.println("Enter 8 to login or 9 to create new user");
        }
    }
  }
}

void executeLoginMenuState(bool recentUserActivity) {
    writeScreenString ("Enter ID, please...");
  String userInput = "";
  
  if (!recentUserActivity) {
    m_currentState = E_DEVICE_STATES_STATUS;
  }
  else {
    Serial.println("Add userID");
    String userID= waitForKeypadInput(10000000);
    if (userID!=""){
  

        
      
      userInput = waitForKeypadInput(100000000);
    
      Serial.println(userInput);
      if (userInput != "") {
      }

        if (checkPasswordWrapper(userInput, m_key)) {
        Serial.println("Login success...");
        m_currentState = E_DEVICE_STATES_DISPLAY_MENU;
      }
      else {
        Serial.println("Login Failed...");
        m_currentState = E_DEVICE_STATES_START_MENU;
      }
    }
    else {
      Serial.println("Timing out...");
      m_recentUserActivity = false;
    }
  }
}

void executeCreateUserState(bool recentUserActivity) {
  if (!recentUserActivity) {
    m_currentState = E_DEVICE_STATES_STATUS;
  }
  else {
    
    Serial.println("Create new user...");
    //TODO -- create user
    m_currentState = E_DEVICE_STATES_DISPLAY_MENU;
  }
}

void executeDisplayMenuState(bool recentUserActivity) {
  Serial.println("Display menu...");
  if (!recentUserActivity) {
    m_currentState = E_DEVICE_STATES_STATUS;
  }
  else {
    //TODO -- display some menu
    m_recentUserActivity = false;
  }
}

void executeStatusState(bool recentUserActivity) {
  char readKey;
  
  if (!recentUserActivity) {
    if (m_statusTimeoutCounter > C_TIMEOUT_THRESHOLD) {
      m_currentState = E_DEVICE_STATES_IDLE;
      m_statusTimeoutCounter = 0;
      Serial.println("Timing out...");
    }
    else {
      m_statusTimeoutCounter += 1;
    }
  }
  else {
    m_statusTimeoutCounter = 0;
    m_currentState = m_lastState;
    m_recentUserActivity = true;
    m_userSelection = 0;
  }
}

/******************************************************************************
LCD Functions
******************************************************************************/
void resetScreen(int wait) {
  #ifdef HARDWARE_ENABLED
  for (int i = 0; i < C_LCD_ROWS; i++) {
    for (int j = 0; j < C_LCD_COLS; j++) {
      m_lcdInstance.setCursor(j, i);
      m_lcdInstance.print(" "); 
    }
  }
  delay(wait);
  #endif
}

void writeScreenChar (char input[]) {
  #ifdef HARDWARE_ENABLED
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
  #endif
}

void writeScreenString(String input) {
  #ifdef HARDWARE_ENABLED
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
  #else
    Serial.println(input);
    delay(1000);
  #endif
}

/******************************************************************************
KEYPAD Functions
******************************************************************************/
bool exitIdleMode() {
  Serial.println ("In exit Idle mode");
  String keypad = readKeypad();
  if (keypad != "") {
    Serial.println (keypad);
    Serial.println ("Read Keypad");
    return true;
  }
  else {
    return false;
  }
}

String waitForKeypadInput(unsigned long timeout) {
  Serial.println(timeout);
  String t_lastKeyPress = "";
  String t_userInput = "";
  int t_elapsedSinceLastKeyPress = 0;
  while (t_lastKeyPress != "#" && t_elapsedSinceLastKeyPress < timeout) {
    Serial.println("In while loop");
    t_lastKeyPress = readKeypad();
    if (t_lastKeyPress != "" && t_lastKeyPress != "#") {
      t_elapsedSinceLastKeyPress = 0;
      t_userInput = t_userInput + t_lastKeyPress;
      Serial.println(t_userInput);
    }
    else {
      t_elapsedSinceLastKeyPress += 1;
      Serial.println("here");
    }
  }
  
  if (t_elapsedSinceLastKeyPress == timeout && t_userInput == "") {
    writeScreenString("TIMEOUT");
    return "";
  }
  else {
    return t_userInput;
  }
}

String readKeypad() {
  #ifndef HARDWARE_ENABLED
  char t_char = m_keypadInstance.getKey();
  while (t_char == NO_KEY) {
    t_char = m_keypadInstance.getKey();
    
  }
  String t_key = String(t_char);
  return t_key;
  
  /*if (t_char != NO_KEY) {
  String t_key = String(t_char);
  Serial.println(t_key);
    return t_key;
  }
  else {
    return "";
  }*/
  #else
  String t_key="";
  if (Serial.available() > 0) {
    t_key = Serial.readString();
   return t_key.substring(0, 1);
    //return String(t_key);
  }
  else {
    return "";
  }
  #endif
}

void correctKey() {
  writeScreenString("KEY ACCEPTED...");
}

void incorrectKey() {
  writeScreenString("KEY REJECTED!");
}

bool checkPassword(String input, String key) {
  if (input.length() == key.length()) {
    for (int i = 0; i < input.length(); i++) {
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

bool checkPasswordWrapper(String input, String key) {
  if(checkPassword(input, key)) {
    correctKey();
    return true;
  }
  else {
    incorrectKey();
    return false;
  }
}
