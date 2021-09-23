// Basic_Audio_Input
/*
 * Politecnico di Milano, Digital Art 2020/2021
 * Teacher assistant: Giulio Interlandi 
 */

import ddf.minim.*; //import the library

Minim minim; //declare we are using minim
AudioInput in; //choose audio input mode

void setup() {
  size (800, 600); 
  minim = new Minim(this); 

  // use the getLineIn method of the Minim object to get an AudioInput
  in = minim.getLineIn();
}

void draw() { 
  background(0);
  stroke(255);

  float sound = 0; //this is our sound value, it's just a variable

  // here is where the magic happens, we create a cycle in which we connect our variable to detect audio input 
  for (int i = 0; i < in.bufferSize() - 1; i++)
  {
    sound += in.left.get(i);
    sound += in.right.get(i);
  }

  ellipse(width/2, height/2, 50+sound*100, 50+sound*50 );

  ellipse(width/4, height/4, 50+sound*50, 50+sound*50 );

  ellipse(3*width/4, 3*height/4, 50+sound*50, 50+sound*50 );

  ellipse(3*width/4, height/4, 50+sound*50, 50+sound*50 );

  ellipse(width/4, 3*height/4, 50+sound*50, 50+sound*50 );
}
