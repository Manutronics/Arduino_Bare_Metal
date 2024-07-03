#include <stdint.h>

//__init() according with ARV-LIBC linker script

void my_led_on(); 
void my_led_off(); 

void setup() {
    //make PINB5 as an output
    asm volatile("sbi 4, 5");
}

volatile static uint32_t i;

void loop() {
    my_led_on();
    for(i = 0; i < 10000; i++);
    my_led_off();
    for(i = 0; i < 100000; i++);
    my_led_on();
    for(i = 0; i < 10000; i++);
    my_led_off();
    for(i = 0; i < 1000000; i++);
}

int main() {

    setup();

    while(1){
        loop();
    }
    return 0;
}

void my_led_on()
{
    asm volatile("sbi 5, 5");
}

void my_led_off()
{
    asm volatile("cbi 5, 5");
}