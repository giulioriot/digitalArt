/**
 NAME: Maximilien Angelo M. Cura
 DATE: 4 July 2019
 DESC: This is a generative art sketch that imitates "Hommage à Paul Klee" by Frieder Nake.
       https://collections.vam.ac.uk/item/O211685/hommage-a-paul-klee-13965-print-nake-frieder
       
       The artwork is composed around a sort of grid of points, which I created in the anchors[][] structure of the HPKMesh class,
       distributed randomly in several rows across a number of invisible vertical lines. Each anchor of a row is connected to the
       anchors immediately adjacent it by lines, which I have represented using the HPKEdge class. Two vertically adjacent edges may
       be connected by a long line composed of contiguous segments that "bounce" in a random manner between the upper and lower edges,
       which I have represented using the HPKLineNetworkGroup class. Additionally, two or three vertically adjacent edges may be
       connected by a series of vertical lines placed at random between the edges, which I created using the HPKVerticalLineGroup.
       The artwork additionally contains circles of random sizes not generally exceeding 1/7th of total size of the artwork, which
       are placed in seemingly random locations about the image, without respect to any of the other contents; the circles are
       represented by the HPKCircle class.
       
       The process of creating the image proceeds thusly: first, the HPKMesh class is used to create the anchor points and the edges
       between them. Then, the HPKImitation class, which regulates the creation of the artwork as a whole, creates the HPKLineNetworkGroup`s
       and the HPKVerticalLineGroup`s by selecting pairs (or triads, in the case of the HPKVerticalLineGroup`s) of vertically adjacent
       edges at random, and placing them there. Once finished, the circles are placed at random about the image, with sizes following a
       normal distribution to mimic the seeming consistency of sizes present in the original image, as using a uniformly random distribution
       led to a rather more intense variation among the sizes of the circles which did not seem to correspond to the original artwork.
       
       The HPKVerticalLineGroup`s function by selecting a number of uniformly random floating point numbers between 0 and 1, mapping the
       numbers to the x-coordinates of the edges, and placing vertical lines between the edges at the given places. The HPKLineNetworkGroup`s
       work similarly, however, in this case, placements are chosen for both the lower _and_ the upper edges, and then line segments are
       drawn between the placement points, alternating between the lower and upper edges.
       
       The classes HPKColors and HPKRandom are utility classes for ease of use.
       
       A brief note on naming conventions: HPK is an abbreviation of Hommage à Paul Klee.
 */

/** The width of the canvas, in pixels */
public static final int kWidth = 600;
/** The height of the canvas, in pixels */
public static final int kHeight = 600;

/** The number of anchors to be used per row. */
public static final int kAnchorsPerRow = 7;
/** The number of horizontal rows */
public static final int kHorizontals = 9;

/** Used to respond to user input requesting that a new imitation be generated */
private boolean flag_regenerate = true;
/** Used to flag the canvas as "dirty" (i.e. that the artwork has changed in some way, and the screen hasn't adjusted to match), so that no cycles are wasted on re-painting the image */
private boolean flag_dirty = false;

/** The main class that coordinates the generation of the imitation */
private HPKImitation imitation = new HPKImitation();

/*
 * Unfortunately, size() cannot normally be called with variables- however, for some reason, this restriction does not apply to the settings() function, so it may be called in such a manner here.
 * Addendum: processing.js doesn't support this
 */
public void settings() {
  size(kWidth + 200, kHeight + 200);
}

/*
 * Set up a couple things that won't need to be changed later.
 */
public void setup() {
	// shim for settings() which processing.js doesn't support.
	size(800, 800);
  // Pass the a PApplet-extending class to HPKRandom so that we can actually use the concrete PApplet.random() and PApplet.randomGaussian() methods from within the static HPKRandom class.
  HPKRandom.init(this);
  // Take care that the circles do not erase whatever may be beneath them when they are drawn.
  // Hex color values seem to follow the form: AARRGGBB where AA is the alpha value, with 0 being transparent, and FF being fully saturated; R, G, and B being red, green, and blue, respectively
  fill(0x00FFFFFF);
}

/*
 * The draw loop.
 */
public void draw() {
  // If the user has indicated that they want the artwork to be generated anew, then do so.
  if(flag_regenerate) {
    // Tell HPKImitation to generate a new version.
    imitation.generate();
    
    // Deactivate the regeneration flag.
    flag_regenerate = false;
    // Indicate that the artwork has changed, so the canvas needs to be re-painted.
    flag_dirty = true;
  }
	
  // Re-paint the canvas
  if(flag_dirty) {
    // Clear the screen and set all pixels to the background colour.
    background(HPKColors.Background);
    
    // The push/popMatrix, the translate(), and the rect() are so that we can have a frame and a border around the image without complicating the calculations for HPKImitation.
    pushMatrix();
    
    // The border is 100px on all sides
    translate(100, 100);
    rect(0,0,kWidth,kHeight);
    // Paint the artwork onto the canvas.
    imitation.paint();
    
    popMatrix();
    // De-activate the dirty flag so that we we're not bleeding cycles
    flag_dirty = false;
  }
}

/**
 * Clicking the mouse will regenerate the image.
 */
public void mouseClicked() {
  flag_regenerate = true;
}

/**
 * A variety of things occur here;
 * If the SPACE key is pressed, then the image is regenerated, just as if mouseClicked() was called.
 * If the S key is pressed, then it will attempt to save a picture of the image to your computer, with the filename "Imitation of Hommage à Paul Klee - Framecapture-####" where #### will be replaced with a series of numbers
 */
public void keyPressed() {
  if(key == ' ') {
    flag_regenerate = true;
  } else if (key == 's' || key == 'S') {
    saveFrame("Imitation of Hommage à Paul Klee - Framecapture-####");
  }
}