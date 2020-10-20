void setup() {
size(800, 800);
background(255);

}

void draw() {
  // feet
  stroke(133, 21, 24);
  fill(133, 21, 24);
  ellipse(385, 475, 20, 20); // left foot (center X, center Y, width, height)
  ellipse(415, 475, 20, 20); // right foot (center X, center Y, width, height)
  // trousers
  stroke(84, 21, 222);
  fill(84, 21, 222);
  rect(375, 425, 50, 10); // pacco (starting X, starting Y, width, height)
  rect(375, 435, 20, 40); // left leg (starting X, starting Y, width, height)
  rect(405, 435, 20, 40); // right leg (starting X, starting Y, width, height)
  // t shirt
  stroke(255, 0, 0);
  fill(255);
  rect(375, 375, 50, 50); // t shirt (starting X, starting Y, width, height)
  triangle(355, 395, 375, 395, 375, 375); // left sleeve (1st angle X, 1st angle Y, 2nd angle X, 2nd angle Y, 3rd angle X, 3rd angle Y)
  triangle(425, 375, 425, 395, 445, 395); // right sleeve (1st angle X, 1st angle Y, 2nd angle X, 2nd angle Y, 3rd angle X, 3rd angle Y)
  // arms
  stroke(252, 211, 181);
  fill(252, 211, 181);
  rect(355, 395, 10, 30); // left arm (starting X, starting Y, width, height)
  rect(435, 395, 10, 30); // right arm (starting X, starting Y, width, height)
  ellipse(360, 425, 10, 10); // left hand (center X, center Y, width, height)
  ellipse(440, 425, 10, 10); // left hand (center X, center Y, width, height)
  // face
  stroke(252, 211, 181);
  fill(252, 211, 181);
  rect(390, 355, 20, 20); // neck (starting X, starting Y, width, height)
  ellipse(400, 350, 30, 30); // face (center X, center Y, width, height)
  stroke(0);
  fill(255);
  point(390, 346);    // left eye
  point(410, 346);    // right eye
  line(390, 355, 410, 355);  // mouth (starting X, starting Y, ending X, ending Y)
  // cap
  stroke(252, 211, 102);
  fill(84, 21, 222);
  rect(380, 340, 40, 4); // cap down (starting X, starting Y, width, height)
  rect(385, 336, 30, 4); // cap middle (starting X, starting Y, width, height)
  rect(390, 332, 20, 4); // cap middle (starting X, starting Y, width, height)

}
