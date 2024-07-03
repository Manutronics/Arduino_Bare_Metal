#include <stdint.h>


__attribute__((naked)) void my_led(uint8_t port, uint8_t pin, uint8_t state);

//__init() according with ARV-LIBC linker script

void setup() {
    //make D13 (PINB5) as an ouput
    asm volatile("sbi 4, 5");
}

volatile static uint32_t i;

void loop() {
    my_led(0x25, 1<<5, 1);
    for(i = 0; i < 10000; i++);
    my_led(0x25, 1<<5, 0);
    for(i = 0; i < 100000; i++);
    my_led(0x25, 1<<5, 1);
    for(i = 0; i < 10000; i++);
    my_led(0x25, 1<<5, 0);
    for(i = 0; i < 1000000; i++);
}

int main() {

    setup();

    while(1){
        loop();
    }
    return 0;
}

// Define a função para definir um bit em uma porta.
// Argumentos passados são atribuídos da esquerda para direita aos registradores
// r25 a r8 respectivamente.
// Argumentos do tipo char são armazenados em 2 bytes.
// Valores de retorno usam registradores de r25 a r18, dependendo do tamanho.
__attribute__((naked)) void my_led(uint8_t port, uint8_t pin, uint8_t state)
{//                                   r25:r24      r23:r22        r21:r20

    // Carrega o valor atual da porta, define o bit, e grava o valor de volta na porta
    asm volatile (
        "eor    r1, r1"     "\n\t"    //Carrega o vaalor 0x00 para dentro de r1
        // Essa linha zera o registrador r25 só pra ter certeza que não contém lixo e o endereço de busca da porta esteja errado
        "ldi    r25, 0x00"  "\n\t"    //Carrega o vaalor 0x00 para dentro de r25


        "movw   r30, r24"   "\n\t"    //Carrega r25-r24 para dentro de r31-r30
        "ld     r24, Z"     "\n\t"    //Carrega um byte apontado pelo registrador Z (r31:r30) para r24      [0x25]-> r24


        "cpse   r20, r1"    "\n\t"    //Compara r1 com r22 e pula a proxima instrução se forem iguais       state == low?
        "rjmp   .+8"        "\n\t"    //Salta para 'or r24, r22'
        
        "com    r22"        "\n\t"    //Faz complementos de um e guarda em r22 (r22 <- 0xFF - r22)
        "and    r24, r22"   "\n\t"    //Faz o 'E' lógico de r24 e r22 e guarda em r24
        "st     Z, r24"     "\n\t"    //Carrega o valor de r24 no local apontado por Z (r31:r30)
        "ret"               "\n\t"    //Retorna para o loop

        "or     r24, r22"   "\n\t"    //Faz o 'OU' lógico de r24 com r22 e quarda em r24
        "rjmp   .-8"        "\n\t"    //Salta para 'st Z, r24'
        ::
    );
}
