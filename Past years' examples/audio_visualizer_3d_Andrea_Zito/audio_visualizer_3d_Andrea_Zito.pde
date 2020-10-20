import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

FFT fft;
AudioPlayer player;
Minim minim;
float rotateAll = 0;
int depth, flashTimer = 0;
boolean fullScreenMode = true;
boolean flash=false;

void setup() {
  stroke(0, 239, 135); 
  strokeWeight(5);

  fullScreen(P3D);
  //size(600, 600, P3D);
  if (fullScreenMode) {
    depth = 0;
  } else {
    depth = -120;
  }

  background(0);
  minim = new Minim(this);
  //player = minim.loadFile("D:/test.mp3");  //600
  player = minim.loadFile("Jamie xx- All Under One Roof Raving.mp3");  //1000
  player.play();
  fft = new FFT(player.bufferSize(), player.sampleRate());
}

void draw() {
  background(217, 30, 67);
  lights();

  fft.forward(player.mix);

  pushMatrix();
  translate(width/2, height/2, depth);
  rotateAll+=0.01;
  rotateY(rotateAll);
  if (rotateAll>255)
    rotateAll = 0;

  if (flash) {
    if (flashTimer > 100) {
      flash = false;
      flashTimer = 0;
    } else {
      flashTimer++;
      background(255 / flashTimer*2, 100 / flashTimer*2, 0);
    }
  }

  for (int i=0; i<24; i++) {

    pushMatrix();

    //rotateY(PI+i*50);
    rotateY(radians(i*15));

    translate(250, 200, 0);
    scale(1);
    if (fft.getBand(i)*5 > 300) {

      if (i==4 && fft.getBand(i)*5 > 1000) {
        flash = true;
      }

      //stroke(255 , 238, 46); 
      //fill(255, 238, 46, 50);
    } else {
      stroke(39, 55, 114); 
      //fill(39, 55, 114, 75);



      //qui ho aggiungto ai valori del colore il valore dei picchi dell'audio per creare un colore random, provalo l'effetto è molto bello ma non hai il controllo su ogni singolo elemento
      //fill(fft.getBand(i)*random(200), fft.getBand(i)*random(200), fft.getBand(i)*random(200), 75);






      //qui invece ho aggiunto uno switch case al ciclo for che hai usato per creare i cubi(i), per ogni caso puoi scegliere un colore
      switch(i) {
      case 0: 
        println("Zero");  // Does not execute
        fill(255, 0, 0);
        break;

      case 1: 
        println("One");  // Prints "One"
        fill(0, 255, 0);
        break;

      case 2: 
        println("2");  // Prints "One"
        fill(0, 0, 0);
        break;
      case 3: 
        println("3");  // Does not execute
        fill(255, 255, 0);
        break;

      case 4: 
        println("4");  // Prints "One"
        fill(0, 255, 255);
        break;

      case 5: 
        println("5");  // Prints "One"
        fill(255, 0, 255, 75);
        break;
      case 6: 
        println("6");  // Prints "One"
        fill(0, 255, 0, 75);
        break;

      case 7: 
        println("2");  // Prints "One"
        fill(0, 0, 0, 75);
        break;
      case 8: 
        println("3");  // Does not execute
        fill(255, 255, 0, 75);
        break;

      case 9: 
        println("4");  // Prints "One"
        fill(0, 255, 255, 75);
        break;

      case 10: 
        println("5");  // Prints "One"
        fill(255, 0, 255, 75);
        break;
      }
      //fine dello switch case
    }
    box(50, (-fft.getBand(i)*5) - 80, 50);  //lerp(display[i], target[i], 1-sensitivity);

    popMatrix();
  }

  popMatrix();
}

void keyPressed() {
  if (key == 'p')
    player.play();
  else if (key == 's')
    player.pause();
}
