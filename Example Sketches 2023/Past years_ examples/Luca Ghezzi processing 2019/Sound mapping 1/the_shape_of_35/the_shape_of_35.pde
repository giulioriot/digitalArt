import ddf.minim.*;
import processing.pdf.*;    // pdf export

Minim minim;
AudioPlayer song;

int spacing = 22;           // space between lines in pixels
int border = spacing*1;     // top, left, right, bottom border
int amplification = 3;      // frequency amplification factor

int y = spacing;
float ySteps;               // number of lines in y direction

void setup() {
  size(800, 800);
  beginRecord(PDF, ".pdf"); // save pdf
  background(245, 245, 240);
  strokeWeight(1);
  stroke(0);
  noFill();

  minim = new Minim(this);
  song = minim.loadFile("song.mp3");
  song.play();
}

void draw() {
  int screenSize = int((width-2*border)*(height-1.5*border)/spacing);
  int x = int(map(song.position(), 0, song.length(), 0, screenSize));

  ySteps = x/(width-2*border);         // calculate amount of lines
  x -= (width-2*border)*ySteps;        // set new x position for each line

  float freqMix = song.mix.get(int(x));
  float freqLeft = song.left.get(int(x));
  float freqRight = song.right.get(int(x));

  float amplitude = song.mix.level();
  float size = freqMix * 0.7 * spacing * amplification;

  float red = map(freqLeft, -1, 1, 0, 150);
  float green = map(freqRight, -1, 1, 0, 190);
  float blue =  map(freqMix, -1, 1, 0, 30);
  float opacity = map(amplitude, 0, 0.8, 0, 100);

  stroke(red, green, blue, opacity * 20);
  strokeWeight(0.5);
  fill(green, red, blue, opacity);
  ellipse(x+border, y*ySteps+border, size, size);
}

void stop() {
  song.close();
  minim.stop();
  super.stop();
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame("_##.png"); // save png of current
  if ((song.isMuted() == false && key == ' ')) song.mute(); // mute song
  else if ((song.isMuted() == true && key == ' ')) song.unmute(); // unmute song
}
