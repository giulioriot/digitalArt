PImage img;
int steps = 6;

void setup() {
  size (1440, 900);
  img = loadImage("A.jpg");
}

void draw() {
  background(255);
  for (int x = 0; x < width; x+= steps) {
    for (int y = 0; y < height; y+= steps) {
      color c = img.pixels[y*img.width+x];
      float b = brightness(c);
      b = map(b, 0, 255, steps, 1);
      stroke(c);
      strokeWeight(b);
      point(x, y);
    }
  }
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame("_##.png"); // save png of current
}
