#include <Arduino.h>
#include "wiring_private.h"

//__init() according with ARV-LIBC linker script

void setup() {
    pinMode(13, OUTPUT);
}

volatile static uint32_t i;

void loop() {
    digitalWrite(13, HIGH);
    delay(100);
    digitalWrite(13, LOW);
    delay(100);
    digitalWrite(13, HIGH); 
    delay(100);
    digitalWrite(13, LOW); 
    delay(2000);
}