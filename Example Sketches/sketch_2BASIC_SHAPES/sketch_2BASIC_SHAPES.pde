// Basic shapes
/*
 * Politecnico di Milano, Digital Art 2021/2022
 * Teacher assistant: Giulio Interlandi 
 */

void setup() {
  background(0); /* rgb colors (R,G,B) ex.(255,0,0) is red */
  size(800, 600);
}

void draw() {

  stroke(255); //set the stroke color

  strokeWeight(5); //set the thickness

  point(400, 200);    //point

  line(400, 300, 400, 400);  //line (starting X, starting Y, ending X, ending Y)

  rect(200, 200, 50, 50); //rectangle (starting X, starting Y, width, height)

  triangle(600, 200, 700, 400, 600, 400); //triangle (1st angle X, 1st angle Y, 2nd angle X, 2nd angle Y, 3rd angle X, 3rd angle Y)

  ellipse(200, 400, 100, 100); //ellipse (center X, center Y, width, height)

  stroke(255, 0, 0); //red color
  point(200, 400);
  stroke(0, 0, 255); //blue color
  point(200, 200);
}
