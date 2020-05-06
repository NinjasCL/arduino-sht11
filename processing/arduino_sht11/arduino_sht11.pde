/*
* Este programa toma los datos del sensor de temperatura
* de arduino y los presenta de forma bonita, además
* crea un archivo con los datos para utilizarlos
* en cualquier otra aplicación
* @author Camilo Castro
* @fecha  29/11/2012
*/


import processing.serial.*;

Serial myPort;  // El objeto utilizado para leer el puerto serial
String val;      // Donde se almacenarán las lecturas en bruto

float temp_c = 0; // Temperatura en Celcius
float temp_f = 0; // Temperatura en Farenheit
float humedad = 0; // Humedad

int delimiterPos = -1; // Necesario para separar los datos en bruto
int altura = 100; // La altura del cuadrado que se dibujará

PrintWriter output; // Para crear un archivo


void setup() 
{

  // Tamaño del lienzo
  size(200, 200);

  // Obtenemos el primer puerto
  // Normalmente es donde ésta Arduino
  // Se recomienda fijar siempre el mismo puerto
  // para el dispositivo, así no hay problemas
  // si se agrega más de uno.
  String portName = Serial.list()[0];
  
  // Los baudios fueron establecidos en el código de Arduino
  // Deben ser los mismos para una correcta comunicación
  myPort = new Serial(this, portName, 9600);
  
  // Se leerá hasta llegar al caracter %
  myPort.bufferUntil('%');
  
  // No dibujar hasta que se tenga datos en el puerto serial
  noLoop();
  
  // Asignamos un archivo log nuevo para cada ejecución
  output = createWriter("sht11"+ day() + month() + year() + hour() + minute() + second() + ".log");
}

void draw()
{

  // Solo para colorear el fondo
  background(Math.round(Math.random() % temp_c) + 25 ,Math.round(Math.random() % humedad) + 50, Math.round(Math.random() % temp_f) + 100);
  
  // Dependiendo de la temperatura, será la altura del cuadrilátero
  if (temp_c <= 0){
     altura = 5;
  } else if(temp_c < 10){
    altura = 25;
  } else if(temp_c < 25){
    altura = 50;
  } else if(temp_c < 35){
    altura = 75;
  } else {
    altura = 100;
  }
  
  // El color dependerá de la altura, la temperatura en Farenheit y la humedad
  fill(altura + 100,temp_f,Math.round(humedad) + 100);
  
  // Dibujamos la figura
  rect(75,50,50,altura);
  
  // Mostramos las lecturas en consola
  System.out.printf("%1.0f ºC\n%1.0f ºF\n%1.0f %s\n",temp_c, temp_f, humedad,'%');
      
  // Escribimos al archivo si hay mediciones
  if(temp_c != 0 && temp_f != 0 && humedad != 0){
    output.print(year() + "/" + month() + "/" + day());
    output.print(" " + hour() + ":" + minute() + ":" + second() + ";");
    output.print(temp_c + ";");
    output.print(temp_f + ";");
    output.println(humedad + "%");
  }
}

// Éste procedimiento ocurre cada vez que el evento
// de recepción de información se gatilla.
// Obtiene los valores y dispara el evento de redibujar
// para mostrar los resultados.

void serialEvent(Serial myPort){
  
  // EX 22.0000000000;71.6719970703;72.72%
  val = myPort.readString();
  
  delimiterPos = -1;
  
  // Lectura de Celcius
  delimiterPos = val.indexOf(';');
  
  temp_c = Float.parseFloat(val.substring(0,delimiterPos));
  
  // Lectura de Farenheit
  val = val.substring(delimiterPos + 1, val.length());
  
  delimiterPos = val.indexOf(';');
  
  temp_f = Float.parseFloat(val.substring(0,delimiterPos));
  
  // Lectura de Humedad
  val = val.substring(delimiterPos + 1, val.length() - 1);
  
  humedad = Float.parseFloat(val);
  
  // Escribimos los resultados a un archivo

  // Se obtiene datos, se muestran
  redraw();
  
  // Enviamos los datos al archivo
  output.flush();
}
