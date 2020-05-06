/*
 * Lee los valores del SHT11 y los entrega por el puerto Serial
 * Tambien activa el PWM si la temperatura esta en un cierto rango
 * @author Camilo Castro
 * @fecha 29/11/2012
 */

#include <SHT1x.h>

// Los puertos necesarios para la lectura en el SHT11
#define dataPin  10
#define clockPin 11


// Definiciones para la salida del PWM
#define FRIA 64 // 25% duty cycle
#define NORMAL 127 // 50% duty cycle
#define CALUROSA 191 // 75% duty cycle
#define ALARMA 255 // 100% duty cycle
#define OFF 0 // 0% duty cycle

// Definiciones para los limites de temperatura En Celcius
#define LIMITE_FRIO 15 
#define LIMITE_NORMAL 25 
#define LIMITE_CALUROSO 40
#define FRIO_CRITICO 0

// Nuestro objeto para interactuar con el sensor de temperatura
SHT1x sht1x(dataPin, clockPin);

// Condicional para salida del PWM
int temperatura = 0;

// Para controlar la salida del PWM
int duty_cycle = 0;

// Pin de salida para el led
int ledPin =  9;

void setup()
{
   // Habilitamos la salida por el puerto serial
   // a 9600 baudios. El lector debe configurarse
   // con el mismo valor
   Serial.begin(9600);
   
   // Habilitamos el Pin 9 para Salida
   pinMode(ledPin, OUTPUT);
}

void loop()
{
  float temp_c;
  float temp_f;
  float humedad;

  // Realizamos la lectura de los valores
  temp_c = sht1x.readTemperatureC();
  temp_f = sht1x.readTemperatureF();
  humedad = sht1x.readHumidity();

  // Enviamos los valores al puerto serial
  Serial.print(temp_c, DEC);
  Serial.print(";");
  Serial.print(temp_f, DEC);
  Serial.print(";");
  Serial.print(humedad);
  Serial.println("%");
  
  // Activacion del PWM dependiendo de la condicion
  temperatura = round(temp_c);
  
  if(temperatura <= FRIO_CRITICO){
    // Temperatura Muy Baja
    duty_cycle = ALARMA;
    
  } else if (temperatura <= LIMITE_FRIO) {
    // Temperatura Fria
    duty_cycle = FRIA;
    
  } else if (temperatura <= LIMITE_NORMAL) {
    // Temperatura Normal
    duty_cycle = NORMAL;
    
  } else if (temperatura <= LIMITE_CALUROSO) {
    // Temperatura Calurosa
    duty_cycle = CALUROSA;
    
  } else {
    // Temperatura Muy Alta
    duty_cycle = ALARMA;
  }
  
  // Mandamos la señal
  analogWrite(ledPin,duty_cycle);

  
  // Esperamos hasta la proxima lectura
  delay(2000);
}
