//Stickman
/*
 Politecnico di Milano, Digital Art 2019/2020
 Teacher assistant: Giulio Interlandi 
 */

void setup() {
  size(200, 200);
  background(255);
}

void draw() {
  ellipseMode(CENTER);
  rectMode(CENTER);
  stroke(0);
  fill(150); //body color
  rect(100, 100, 20, 100); //body
  fill(255); //head color
  ellipse(100, 70, 60, 60); //head
  fill(10,180,100); //eyes color
  ellipse(81, 70, 16, 32); //1st eye
  ellipse(119, 70, 16, 32); //2nd eye
  stroke(0); //legs color
  line(90, 150, 80, 160); //1st leg
  line(110, 150, 120, 160); //2nd leg
}
