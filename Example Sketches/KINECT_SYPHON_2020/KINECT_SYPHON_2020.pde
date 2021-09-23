// Kinect to Syphon
// Depth thresholding by Daniel Shiffman
// From Open Kinect for Processing 
/*
 * Politecnico di Milano, Digital Art 2021/2022
 * Teacher assistant: Giulio Interlandi 
 */

import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import codeanticode.syphon.*;

Kinect kinect;
SyphonServer server;

// Depth image
PGraphics canvas;
PImage depthImg, temp;

// Which pixels do we care about?
int minDepth =  60;
int maxDepth = 860;

// What is the kinect's angle
float angle;

void setup() {
  size(640, 480, P3D);

  kinect = new Kinect(this);
  kinect.initDepth();
  angle = kinect.getTilt();
  // Blank image
  depthImg = new PImage(kinect.width, kinect.height);
  temp = new PImage(width, height);
  canvas = createGraphics(kinect.width, kinect.height, P3D);
  server = new SyphonServer(this, "Processing!");
}

void draw() {
  // Draw the raw image
  image(kinect.getDepthImage(), 0, 0);
  canvas.beginDraw();
  canvas.background(0);
  // Threshold the depth image
  int[] rawDepth = kinect.getRawDepth();
  for (int i=0; i < rawDepth.length; i++) {
    if (rawDepth[i] >= minDepth && rawDepth[i] <= maxDepth) {
      depthImg.pixels[i] = color(255);
    } else {
      depthImg.pixels[i] = color(0);
    }
  }
  // Draw the thresholded image
  temp.copy(depthImg, 0, 0, kinect.width, kinect.height, 0, 0, width, height);
  depthImg.updatePixels();
  // scale(xRatio,yRatio );
  temp.copy(depthImg, 0, 0, kinect.width, kinect.height, 0, 0, width, height);
  canvas.image(depthImg, 0, 0);
  canvas.endDraw();
  image(temp, 0, 0);
  image(depthImg, 0, 0);
  server.sendImage(canvas);
  fill(255);
  text("TILT: " + angle, 10, 20);
  text("THRESHOLD: [" + minDepth + ", " + maxDepth + "]", 10, 36);
}

// Adjust the angle and the depth threshold min and max
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      angle++;
    } else if (keyCode == DOWN) {
      angle--;
    }
    angle = constrain(angle, 0, 30);
    kinect.setTilt(angle);
  } else if (key == 'a') {
    minDepth = constrain(minDepth+10, 0, maxDepth);
  } else if (key == 's') {
    minDepth = constrain(minDepth-10, 0, maxDepth);
  } else if (key == 'z') {
    maxDepth = constrain(maxDepth+10, minDepth, 2047);
  } else if (key =='x') {
    maxDepth = constrain(maxDepth-10, minDepth, 2047);
  }
}
