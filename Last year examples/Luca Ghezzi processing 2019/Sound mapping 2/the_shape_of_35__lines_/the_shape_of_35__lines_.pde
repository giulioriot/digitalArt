import ddf.minim.*;            // minim library
import processing.pdf.*;       // pdf export library
import java.util.Calendar;     // java timestamp

Minim minim;                   // initialize minim
AudioPlayer song;              // setup up player

int spacing = 2;               // distance between lines
int border = 22;               // top, left, right, bottom border
int amplification = 40;        // frequency amplification
int num = 100;                 // resolution in y direction
int cutBack = 2000;           // remove parts from the song end
int cutFront = 1000;          // remove parts from the song start
int pos, counter;

float[] x = new float[num];    // array of values in x direction
float[] y = new float[num];    // array of values in y direction

void setup() {
  size(800, 800);
  minim = new Minim(this);
  song = minim.loadFile("song.mp3");    // load song
 
  song.play();                          // play song
  song.cue(cutFront);                   // cut parts from song beginning

  background(245, 245, 240);
  beginRecord(PDF, ".pdf"); // save pdf
  noFill();
  strokeWeight(1);
  stroke(0);
}

void draw() {
  beginShape();                // start custom shape
  x[0] = pos + border;         // set x and y value of first array item to ‘zero’
  y[0] = border;
  curveVertex(x[0], y[0]);
  for (int i = 0; i < num; i++) {                           // loop through each element in array
    x[i] = pos + border + song.mix.get(i)*amplification;    // assign frequency value at position
    y[i] = map( i, 0, num, border, height-border );         // map ‘i’ to canvas height
    curveVertex(x[i], y[i]);
  }
  x[num-1] = x[0];                     // set x and y value of last array item to ‘zero’
  y[num-1] = height-border;
  curveVertex(x[num-1], y[num-1]);
  endShape();                          // close custom shape
  
  int skip = (song.length() - cutFront - cutBack) / ((width-2*border) / spacing);  // amount to skip song forward, based on spacing
  if (pos + border < width-border) {   // skip song, set new x position
    song.skip(skip);
    pos += spacing;
  } else {
    minim.stop();                      // stop song if canvas is full
  }
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame("_##.png"); // save png of current
  if ((song.isMuted() == false && key == ' ')) song.mute(); // mute song
  else if ((song.isMuted() == true && key == ' ')) song.unmute(); // unmute song
}
