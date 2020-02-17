/*
*/

#include <LiquidCrystal.h>
#include <string.h>


const int analogPin = A0;

const int buttonPin = 2;     // the number of the pushbutton pin
const int ledPin =  14;      // the number of the LED pin

LiquidCrystal lcd(12, 11, 7, 6, 5, 4);

void setup() {
  lcd.begin(16, 2);  
  // initialize the LED pin as an output:
  pinMode(ledPin, OUTPUT);
  // initialize the pushbutton pin as an input:
  pinMode(buttonPin, INPUT);
}

int widthLCD = 16;
int cnt = 0;

int lastCol = 0; 

int row = 0;

int buttonState = 0;

void loop() {
  buttonState = digitalRead(buttonPin);

  // check if the pushbutton is pressed. If it is, the buttonState is HIGH:
  if (buttonState == HIGH) {
    // turn LED on:
    digitalWrite(ledPin, HIGH);
  } else {
    // turn LED off:
    digitalWrite(ledPin, LOW);
  }

if (cnt % widthLCD == 0) {
  cnt = 0; // Reset your cycle counter in terms of 0 to 15
}

String stri = "Hello World!";

lcd.setCursor(0, 0);
lcd.print("                ");
lcd.setCursor(0, 1);
lcd.print("                ");
delay(100);

if (buttonState == HIGH) {
  row += 1;
  row = row % 2;
}
for (int i = 0; i < stri.length(); i++) {

  char c = stri[i];
    int columnToPrintTo = (i + cnt) % widthLCD;
    lcd.setCursor(columnToPrintTo, row);
    lcd.print(c);
    
    if (i == 0) {
      lastCol = columnToPrintTo;
    }
  // write to the columnToPrintTo on the LCD screen

}

cnt = cnt + 1; // Increment your cycle counter
delay(500);
  
}
