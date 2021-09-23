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
/** Used to indicate whether or not the active distortion filter is being used */
private boolean flag_distort = false;
/** Used to flag the canvas as "dirty" (i.e. that the artwork has changed in some way, and the screen hasn't adjusted to match), so that no cycles are wasted on re-painting the image */
private boolean flag_dirty = false;

/** Used by the active distortion filter to compensate for any randomness that may occur in the timing of the looping of the draw() method */
private int prev_draw_time = -1;

/** The main class that coordinates the generation of the imitation */
private HPKImitation imitation = new HPKImitation();

/*
 * Unfortunately, size() cannot normally be called with variables- however, for some reason, this restriction does not apply to the settings() function, so it may be called in such a manner here.
 * Addendum: processing.js doesn't support this
 */
/*
public void settings() {
  size(kWidth + 200, kHeight + 200);
}
*/
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
  } else {
    // If not actively regenerating, then apply the active distortion filter, if the user has indicated they wish it to be so.
    if(flag_distort) {
      // Get the amount of time since the program started, in milliseconds
      int curr_draw_time = millis();
      // If this is the first time it's running, tdelta will be abnormally large, whatever we do- so, we just ignore the first pass, except for updating
      // prev_draw_time to stabilize the tdelta value - otherwise, the artwork will have a sudden large distortion and then go on quietly buzzing, which is
      // not the desired effect.
      
      // If this isn't the first time the distortion filter has been applied, then
      if(prev_draw_time != -1) {
        // Figure out how much time has passed since the last pass, and then apply an adjuster so that the distortion doesn't occur too quickly.
        float tdelta = (curr_draw_time - prev_draw_time) / 5;
        // Distort the anchors
        imitation.mesh.distortAnchors(tdelta);
        // Get ready for the next pass
      }
      prev_draw_time = curr_draw_time;
      // Indicate that the image has changed.
      flag_dirty = true;
    }
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
 * If the ENTER/RETURN key is pressed, then the active distortion filter will be toggled.
 */
public void keyPressed() {
  if(key == ' ') {
    flag_regenerate = true;
  } else if (key == 's' || key == 'S') {
    saveFrame("Imitation of Hommage à Paul Klee - Framecapture-####");
  } else {
    switch(keyCode) {
      case ENTER:
      case RETURN:
        flag_distort = !flag_distort;
        if(flag_distort == false) {
          prev_draw_time = -1;
        }
        break;
    }
  }
}

/**
 * A simple class representing one of the circles present on the artwork.
 */
public class HPKCircle {
  
  /** The center point of the circle */
  PVector center;
  /** The radius of the circle */
  float radius;
  
  /** Simple data initialization constructor.
   *
   * @param center The center of the circle
   * @param radius The radius of the circle
   */
  public HPKCircle(PVector center, float radius) {
    this.center = center;
    this.radius = radius;
  }
  
  /**
   * Will paint the circle on the canvas.
   */
  public void paint() {
    // circle(x,y,d) takes
    //     x = x-coordinate of the center
    //     y = y-coordinate of the center
    //     d = the diameter of the circle
    // Thus, we use this.radius * 2

    // scratch all that, processing.js doesn't have circle()
    ellipse(this.center.x, this.center.y, this.radius * 2, this.radius * 2);
  }
}

/**
 * Datapack class containing the colors to be used in the imitation of the artwork
 * All values sampled directly from the original image.
 */
public static class HPKColors {
  
  // It seems like background() ignores the alpha byte, but we'll put it in just in case.
  public static int Background = 0xFFF4EFEB;
  public static int Stroke = 0xFF282725;
}

/**
 * Represents a line between to anchor points.
 */
public class HPKEdge {
  
  /** The left anchor point */
  public PVector left;
  /** The right anchor point */
  public PVector right;
  
  /** The stroke color can be set independently like this for debugging reasons. */
  public int stroke_color = HPKColors.Stroke;
  
  public HPKEdge(PVector a, PVector b) {
    this.left = a;
    this.right = b;
  }
  
  /** Paint the edge on the canvas */
  public void paint() {
    stroke(this.stroke_color);
    line(this.left.x, 
         this.left.y, 
         this.right.x, 
         this.right.y);
  }
  
  /**
   * Get the distance between the x-coordinates of the two anchor points.
   */
  public float getXRange() {
    return max(this.left.x, this.right.x) - min(this.left.x, this.right.x);
  }
  
  /**
   * Maps a floating point value between 0..1 to a point along the edge.
   */
  public PVector getPointByXOffset(float xoff) {
    /* Get a vector representing the offsets between the end-points, i.e. <delta_x, delta_y> */
    PVector offset = PVector.sub(this.right, this.left);
      /* Then scale horizontally & vertically by the x offset */
    offset.mult(xoff);
    return PVector.add(
      offset,
      /* Then add it to the base point again to fix it to the proper point in the coordinate space */
      this.left);
  }
}
/**
 * The central driver and carrier class.
 */
public class HPKImitation {
  
  /** The anchor point mesh*/
  public HPKMesh mesh;
  
  /** The array of edges between the anchor points */
  public HPKEdge[] edges;
  
  /** The array of all the vertical line groups */
  public HPKVerticalLineGroup[] vertical_line_groups;
  
  /** The array of all the "line networks" */
  public HPKLineNetworkGroup[] line_network_groups;
  
  /** The array of all the circles */
  public HPKCircle[] circles;
  
  /**
   * Generates a new imitation
   */
  public void generate() {
    // Create a new anchor point mesh
    this.mesh = new HPKMesh(new PVector(kAnchorsPerRow, kHorizontals));
    this.mesh.generateAnchors();
    
    // Generate a set of edges from the anchor points
    this.edges = this.mesh.generateEdges();
    
    // Brief aside about the indexing of the edges array:
    //   # of edges per row = this.mesh.anchors[0].length - 2
    //   # of rows = this.mesh.anchors.length
    //   thus, vertically adjacent edges will be:
    //      this.edges[n + k(this.mesh.anchors[k].length - 2)] where
    //          n is the placement of the edge within the row
    //          k is the row number
    
    // We use ArrayList<>`s because we the groupings are created on the fly, so we don't know how many we'll end up with
    ArrayList<HPKVerticalLineGroup> vertical_line_groups = new ArrayList<HPKVerticalLineGroup>();
    ArrayList<HPKLineNetworkGroup> line_network_groups = new ArrayList<HPKLineNetworkGroup>();
    
    // Get the width of a row of anchor points
    final int row_width = this.mesh.anchors[0].length - 2;
    
    // `occupied_spaces` is used to keep track of which "space"s between edges are occupied.
    // We have to add 1 to mesh.anchors.length because, as we're counting spaces, we need to count the borders of the canvas as pseudo-edges
    // (and, in fact, we do create HPKEdge`s representing them, but they're never added to the `edges` array).
    boolean[][] occupied_spaces = new boolean[this.mesh.anchors.length + 1][row_width];
    // Initialize occupied_spaces to be all false
    for(int i = 0;i < occupied_spaces.length;i++) {
      for(int j = 0;j < occupied_spaces[i].length;j++) {
        occupied_spaces[i][j] = false;
      }
    }
    
    // Go through all of the "space"s in the anchor point grid, and for each unoccupied space, decide whether to attempt to create:
    //    a 2-row vertical line group (10% chance), falling through to 1-row vertical group if circumstances prevent it (which only occur for the last row)
    //    a 1-row vertical line group (20% chance, excluding the fall-through from the 2-row vertical groups)
    //    a 1-row line network group (20% chance)
    //    nothing (50% chance)
    
    // Iterate through the rows - note that we start at -1, representing the fact that the "top edge" (i.e. the upper border) is not represented in the `edges` array.
    for(int row = -1;row < this.mesh.anchors.length;row++) {
      // Iterate through each row
      for(int offset_in_row = 0;offset_in_row < row_width;offset_in_row++) {
        // If this "space" isn't occupied.
        // We have to use row + 1 in occupied spaces because `row` starts from -1
        if(!occupied_spaces[row + 1][offset_in_row]) {
          // This is the value that decides what to do with the space
          final float decision = HPKRandom.Float(0, 1);
          
          // 10% chance to:
          if(decision < 0.1 && /* Try to create a 2-row grouping of vertical lines, assured that: */
            /* a) it is not the last row - since we are going from top to bottom, the vertically adjacent space directly below the current one will always be open _unless_ we're on the last row */
            (row < (this.mesh.anchors.length - 1)
            /* or b) it *is* the last row, and the space directly above the current space is unoccupied */
            || !occupied_spaces[row][offset_in_row])) { // If these constraints are not met, then it will fall through to the second segment which'll creates a 1-row grouping of vertical lines
            
            // Find the row index of the upper and lower edges, and fill out the appropriate spots of the `occupied_spaces` arrays.
            int high_row, low_row;
            if(row == this.mesh.anchors.length - 1) {
              // If it's the last row, then we take up the space directly above the current one
              // The lower edge will be low_row = this.mesh.anchors.length, which corresponds to the bottom of the canvas
              // and the upper edge will be 2 row indices above that
              high_row = row - 1;
              low_row = row + 1;
              
              occupied_spaces[row][offset_in_row] = true;
              occupied_spaces[row + 1][offset_in_row] = true;
            } else {
              // We lump the first row and middle row cases together because the `occupied_spaces` code works the same for both
              high_row = row;
              low_row = row + 2;
              occupied_spaces[row + 1][offset_in_row] = true;
              occupied_spaces[row + 2][offset_in_row] = true;
            }
            
            // Then, from the row indices generated above, find the corresponding HPKEdge`s
            HPKEdge lower, upper;
            if(high_row == -1) {
              // If it's the first row, grab the 2nd edge down from the top of the canvas
              lower = this.edges[offset_in_row + row_width];
              // Create a "fake" edge at the top of the canvas - we do this here because it doesn't belong in mesh.edges
              upper = new HPKEdge(new PVector(lower.left.x, 0), new PVector(lower.right.x, 0));
            } else if (low_row == this.mesh.anchors.length) {
              // If it's the last row, then grab the 2nd edge from the bottom of the canvas.
              upper = this.edges[offset_in_row + ((high_row) * row_width)];
              // Create a "fake" edge at the bottom of the canvas
              lower = new HPKEdge(new PVector(upper.left.x, kHeight), new PVector(upper.right.x, kHeight));
            } else {
              // Otherwise, just grab the rows in a "normal" manner
              upper = this.edges[offset_in_row + (high_row * row_width)];
              lower = this.edges[offset_in_row + (low_row * row_width)];
            }
            // Then, simply create the vertical line group, and add it to the list
            HPKVerticalLineGroup vlg = new HPKVerticalLineGroup(upper, lower);
            vertical_line_groups.add(vlg);
          } else if(decision < 0.5) { // handle both of the 1-row cases in the same block for simplicity, as they both take the same parameter set.
            // Set the space as occupied
            occupied_spaces[row + 1][offset_in_row] = true;
            // Find the HPKEdge`s bounding the space
            HPKEdge lower, upper;
            if(row == -1) {
              // Short for edges[offset_in_row + 0 * row_width], i.e. row 0
              lower = this.edges[offset_in_row];
              // Create a "fake" edge at the top of the canvas
              upper = new HPKEdge(new PVector(lower.left.x, 0), new PVector(lower.right.x, 0));
            } else if(row == this.mesh.anchors.length - 1) {
              upper = this.edges[offset_in_row + (row * row_width)];
              // Create a "fake" edge at the bottom of the canvas
              lower = new HPKEdge(new PVector(upper.left.x, kHeight), new PVector(upper.right.x, kHeight));
            } else {
              upper = this.edges[offset_in_row + (row * row_width)];
              lower = this.edges[offset_in_row + ((row + 1) * row_width)];
            }
            
            // Create the appropriate type of group, and then add it to the appropriate list
            if(decision < 0.3) {
              HPKVerticalLineGroup vlg = new HPKVerticalLineGroup(upper, lower);
              vertical_line_groups.add(vlg);
            } else {
              HPKLineNetworkGroup lng = new HPKLineNetworkGroup(upper, lower);
              line_network_groups.add(lng);
            }
          }
        }
      }
    }
    
    // Convert the ArrayList<>`s to arrays
    this.vertical_line_groups = vertical_line_groups.toArray(new HPKVerticalLineGroup[vertical_line_groups.size()]);
    this.line_network_groups = line_network_groups.toArray(new HPKLineNetworkGroup[line_network_groups.size()]);
    
    // Create the circles
    
    // First, allocate 5 to 11 HPKCircles 
    this.circles = new HPKCircle[HPKRandom.Integer(5, 11)];
    for(int i = 0;i < this.circles.length;i++) {
      // Quick rejection algorithm to make sure none of the circles overlap 
      boolean permissible;
      HPKCircle tmp;
      do {
        permissible = true;
        // Coordinates of the center point, at least 5px away from the borders of the canvas
        float x = HPKRandom.Integer(5, kWidth - 5);
        float y = HPKRandom.Integer(5, kHeight - 5);
        tmp = new HPKCircle(new PVector(x,y),
                            HPKRandom.BoundedNormal(
                              /* center on \approx 2/3 of (The average height of a horizontal row) */
                              2 *(kHeight / kHorizontals) / 3,
                              /* stddev \approx 1/4 of (The average height of a horizontal row) */
                              (kHeight / kHorizontals) / 4,
                              /* We're always at least 5px away from the canvas borders, so go with radius = 3px as a safe minimum */
                              3,
                              /* Make sure that we don't hit any of the borders */
                              min(min(x, y), min(kWidth - x, kHeight - y))));
        // Go through the previously created circles
        for(int j = 0;j < i;j++) {
          // let a and b be 2d vectors representing the centers of the circles; let ra be the radius of the circle centered on a, rb that of the one centered on rb
          // ||a-b|| < (ra+rb) => the circles overlap
          // ||a-b|| = (ra+rb) => the circles touch
          // ||a-b|| > (ra+rb) => the circles do not touch or overlap
          // where ||v|| denotes the magnitude of the vector v
          if(PVector.sub(this.circles[j].center, tmp.center).mag() <= (tmp.radius + this.circles[j].radius)) {
            permissible = false;
          }
        }
      } while(!permissible);
      this.circles[i] = tmp;
    }
  }
  
  /**
   * Paint all the components onto the canvas
   */
  public void paint() {
    // First, the edges
    for(HPKEdge edge : this.edges) {
      edge.paint();
    }
    // Then, the vertical line groups
    for(HPKVerticalLineGroup vline_group : this.vertical_line_groups) {
      vline_group.paint();
    }
    // Then, the line network groups
    for(HPKLineNetworkGroup lnet_group : this.line_network_groups) {
      lnet_group.paint();
    }
    // And finally the circles
    for(HPKCircle circle : this.circles) {
      circle.paint();
    }
  }
}
public class HPKLineNetworkGroup {
  
  /** The upper bounding edge */
  public HPKEdge upper_edge;
  /** The lower bounding edge */
  public HPKEdge lower_edge;
  
  /** The placement anchors on the upper edge */
  float upper_anchors[];
  /** The placement anchors on the lower edge */
  float lower_anchors[];
  
  public HPKLineNetworkGroup(HPKEdge upper, HPKEdge lower) {
    this.upper_edge = upper;
    this.lower_edge = lower;
    
    this.generatePlacements();
  }
  
  public void generatePlacements() {
    // Decide on the number of lines based on the lengths of the edges
    final float x_range = this.upper_edge.getXRange();
    // Numbers are a bit higher, because HPKLineNetworkGroup needs to be rather denser than HPKVerticalLineGroup
    final int base_num_anchors = (int) HPKRandom.BoundedNormal(
      x_range * 0.042,
      x_range * 0.09,
      x_range * 0.32,
      x_range * 0.50
    );
    
    // Let one edge have 1 more placement anchors than the other
    if(HPKRandom.Integer(0, 1) == 0) {
      this.upper_anchors = new float[base_num_anchors];
      this.lower_anchors = new float[base_num_anchors + 1];
    } else {
      this.lower_anchors = new float[base_num_anchors];
      this.upper_anchors = new float[base_num_anchors + 1];
    }
    
    // Fill out the placement anchor arrays, using uniformly distributed numbers between 0 and 1
    // I tried Perlin noise and normal distribution, but they didn't quite work right.
    for(int iu = 0;iu < this.upper_anchors.length;iu++) {
      this.upper_anchors[iu] = HPKRandom.Float(0, 1);
    }
    for(int il = 0;il < this.lower_anchors.length;il++) {
      this.lower_anchors[il] = HPKRandom.Float(0, 1);
    }
  }
  
  /**
   * Draw the line segments onto the canvas
   */
  public void paint() {
    // -1 because we're doing edges, not points
    final int num_segments = min(upper_anchors.length, lower_anchors.length) - 1;
    for(int i = 0;i < num_segments;i++) {
      // Get the placement anchors from both edges
      PVector a, b;
      a = this.upper_edge.getPointByXOffset(this.upper_anchors[i]);
      b = this.lower_edge.getPointByXOffset(this.lower_anchors[i + 1]);
      // Draw the line between them
      line(a.x, a.y, b.x, b.y);
    }
  }
}
/**
 * HPKMesh deals with the anchor points, and also with generating edges.
 */
public class HPKMesh {
  
  /**
   * The "grid" of anchor points.
   * Has the special property that for any appropriate values of row and offset_in_row,
       anchors[row][offset_in_row].x == anchors[row + k][offset_in_row].x
       where k is any appropriate integer
   * i.e. all vertically adjacent anchor points in the grid will have the same x-coordinate 
   */
  PVector[][] anchors;

  /** Dimensions of the anchor point array
   * dim.x = # of flex points
   * dim.x + 2 = # of anchors per horizontal (left and right edges count too)
   * dim.y = # of horizontals
   */
  PVector dim;

  public HPKMesh(PVector dim) {
    this.dim = dim;
    this.anchors = new PVector[(int)this.dim.y][(int)this.dim.x + 2];
  }

  public void distortAnchors(float tdelta) {
    for (int y = 0; y < this.anchors.length; y++) {
      float average = 0;
      for (int x = 0; x < this.anchors[y].length - 1; x++) {
        average += this.anchors[y][x].y;
      }
      average /= (this.anchors[y].length - 1);
      for (int x = 0; x < this.anchors[y].length - 1; x++) {
        this.anchors[y][x].y = HPKRandom.BoundedNormal(this.anchors[y][x].y,
                                                       tdelta / (this.anchors[y][x].y - average),
                                                       y == 0 ? 0 : this.anchors[y - 1][x].y, 
                                                       y == (this.anchors.length - 1) ? kHeight : this.anchors[y + 1][x].y);
      }
    }
  }

  /**
   * Generates the anchor points
   */
  public void generateAnchors() {
    // Generate the x-coordinates for the anchor points along a set of fixed lines
    int[] vertical_anchors = this.generateBanding((int)this.dim.x, kWidth);
    // FIXED: changed generateBanding() to do this automatically
    // (EDIT: NO LONGER) Necessary, because integer division is lossy (i.e. band_width in generateBanding()), which causes the final anchor to be slightly less than kWidth, which causes problems
    //vertical_anchors[(int)this.dim.x] = kWidth;
    
    // The procedure for generating the "bases" for the y-coordinates is somewhat different: a spot is chosen within each band, and placed in horizontal_anchors
    
    // NOTE: horizontal_borders.length == this.dim.y + 1, so compensate
    int[] horizontal_borders = this.generateBanding((int)this.dim.y, kHeight);
    int[] horizontal_anchors = new int[(int)this.dim.y];
    
    for (int i = 0; i < (int)this.dim.y; i++) {
      horizontal_anchors[i] = (int) HPKRandom.BoundedNormal(
      /* center on the middle of the band */
        (float) (horizontal_borders[i] + ((horizontal_borders[i+1] - horizontal_borders[i]) / 2)), 
      /* stddev = band_width / 6; Empirical rule means that 99.7% of the time, BoundedNormal only needs one iteration-also makes it turn out just right */
        (float) ((horizontal_borders[i+1]-horizontal_borders[i]) / 6), 
      /* bounds are the borders */
        (float) horizontal_borders[i], 
        (float) horizontal_borders[i+1]
        );
    }

    // Create the first "column" of anchor points as a base for all the rest
    for (int i = 0; i < horizontal_anchors.length; i++) {
      this.anchors[i][0] = new PVector(vertical_anchors[0], horizontal_anchors[i]);
    }
    // Iterate through, creating the anchor points at normally distributed spots centered around the previous anchor point in each row
    // This has the side effect of necessitating the vertical_anchors.length-1
    for (int ix = 0; ix < vertical_anchors.length - 1; ix++) {
      for (int iy = 0; iy < horizontal_anchors.length; iy++) {
        this.anchors[iy][ix+1] = new PVector (vertical_anchors[ix+1], 
          HPKRandom.BoundedNormal(
        /* centered on the y-coord of the previous anchor in the row */
          this.anchors[iy][ix].y, 
        /* stddev = band_width * sin(PI/24) */
          (horizontal_borders[iy+1]-horizontal_borders[iy]) * sin(PI/24), 
        /* minimum and maximum are the horizontal borders */
          horizontal_borders[iy], 
          horizontal_borders[iy+1]
          )
          );
      }
    }
  }

  /**
   * Generate a set of edges from the anchor point mesh
   */
  public HPKEdge[] generateEdges () {
    ArrayList<HPKEdge> edges = new ArrayList<HPKEdge>();
    for (int iy = 0; iy < this.anchors.length; iy++) {
      for (int ix = 0; ix < this.anchors[iy].length - 2; ix++) {
        HPKEdge edge = new HPKEdge(this.anchors[iy][ix], this.anchors[iy][ix+1]);
        edges.add(edge);
      }
    }
    return edges.toArray(new HPKEdge[edges.size()]);
  }

  /**
   * Divides a range of numbers into a series of "band"s of random sizes, and then returns an array of the borders between the bands.
   * For example, `generateBanding(2, 8)` might return `[0 5 7 8]`.
   */
  public int[] generateBanding(int bands, int maximum) {
    // Number of borders necessary to border the bands
    final int num_borders = bands + 1;
    // Starting width of each band
    // Note: integer division is lossy, so we have to set the last border to `maximum` at the end of the function
    final int band_width = maximum/bands;

    // Generate borders of the bands
    int[] borders = new int[num_borders];
    for (int i = 0; i < num_borders; i++) {
      borders[i] = i * band_width;
    }
    
    // Distort the borders
    
    // Choose the number of iterations of distortion to undergo
    final int iterations = HPKRandom.Integer(4, 7);
    for (int j = 0; j < iterations; j++) {
      // Don't move the first and last borders: they define the minimum and maximum of the image, respectively: if they change, it could seriously skew the image
      for (int i = 1; i < num_borders - 1; i++) {
        borders[i] = (int) HPKRandom.BoundedNormal(
        /* Center on the existing border */
          (float) borders[i], 
        /* Stddev = (average of the width of the bands on either size) / 3 */
          (float) (borders[i+1] - borders[i-1]) / 4, 
        /* Don't infringe on the adjacent bands by too much */
          (float) borders[i-1] + HPKRandom.BoundedNormal(0.65, 0.1, 0, 1) * (borders[i] - borders[i-1]), 
          (float) borders[i+1] - HPKRandom.BoundedNormal(0.65, 0.1, 0, 1) * (borders[i+1] - borders[i])
          );
      }
    }
    
    // Compensate for the lossy integer division
    borders[borders.length - 1] = maximum;

    return borders;
  }
}
/**
 * Utility class for generating random numbers
 */
public static class HPKRandom {
  
  /**
   * @see HPKRandom.init()
   */
  private static PApplet appletInstance;
  
  /** Initializer
   * As random() and randomGaussian() are both methods of the PApplet class (which is the base class of the "invisible" class that encapsulates setup()/settings()/draw()/etc. in the main sketch file, we must somehow obtain an/the instance of that class
   * Since we don't know how Processing handles the "invisible" main class (i.e. whether there are invisible overrides of methods from PApplet), we should probably use the actual instance
   * Thus, best practice would be:
   * <code>
   void setup() {
     // Give HPKRandom a source of random numbers
     HPKRandom.init(this);
   }
   * </code>
   *
   * @internal This was a shim that I needed for the desktop version of Processing, given the way I set up the project; not sure whether it's required for the version I uploaded to openprocessing.org
   */
  public static void init(PApplet instance) {
    HPKRandom.appletInstance = instance;
  }
  
  /*
   * Functions dealing with generating uniformly distributed random numbers
   */
  
  public static float Float(float min, float max) {
    return HPKRandom.appletInstance.random(min, max);
  }
  
  public static int Integer(int min, int max) {
    return (int)HPKRandom.appletInstance.random(min, max);
  }
  
  /*
   * Functions dealing with generating normally distributed random numbers
   */
   
  // The "root" function here
  public static float Gaussian() {
    return HPKRandom.appletInstance.randomGaussian();
  }

  
  public static float Normal(float mean, float stddev) {
    // Any normal distribution N(m, s) may be modeled as m + sN(0, 1), and N(0, 1) happens to be the Gaussian normal distribution, a.k.a. the standard normal distribution
    return mean + (stddev * HPKRandom.Gaussian());
  }
  
  /** Bounded normally distributed random numbers
   * As generating numbers from a normal distribution can give extreme outliers (i.e. >|3 * stddev|, this may prove difficult when there must be bounds on the number
   * Using constrain() on this would result in a distribution very much different from the true normal distribution, thus, we simply keep sampling numbers until one is found that is in range
   * Essentially, it's a simple rejection algorithm
   */
  public static float BoundedNormal(float mean, float stddev, float minimum, float maximum) {
    float ret;
    do {
      ret = HPKRandom.Normal(mean, stddev);
    } while (ret < minimum || ret > maximum);
    return ret;
  }
}
public class HPKVerticalLineGroup {
  
  /* The upper bounding edge */
  public HPKEdge upper_edge;
  
  /* The lower bounding edge */
  public HPKEdge lower_edge;
  
  /* The placement anchors for the vertical lines */
  float[] placements;
  
  public HPKVerticalLineGroup(HPKEdge a, HPKEdge b) {
    this.upper_edge = a;
    this.lower_edge = b;
    
    this.generatePlacements();
  }
  
  public void generatePlacements() {
    // Decide on the number of lines based on the lengths of the edges
    float x_range = this.upper_edge.getXRange();
    int num_lines = (int)
      // Numbers based on experimnetation
      HPKRandom.BoundedNormal(
        /* center on 4% coverage */
        x_range * 0.04,
        /* stddev of 9% */
        x_range * 0.09,
        /* We want minimum 2% coverage */
        x_range * 0.02,
        /* No more than 20% of the area should be covered */
        x_range * 0.20
      );
    
    // Fill out the placement anchor arrays, using uniformly distributed numbers between 0 and 1
    this.placements = new float[num_lines];
    for(int i = 0;i < num_lines;i++) {
      // Perlin noise just doesn't quite give the right distribution here... just a random Float seems to be better
      //this.placements[i] = this.perlin.noise(HPKRandom.BoundedNormal(2.1, 0.3, 0, 10));
      this.placements[i] = HPKRandom.Float(0, 1);
    }
  }
  
  /**
   * Paint the vertical line group onto the canvas
   */
  public void paint() {
    for(float placement: placements) {
      PVector upper_point = this.upper_edge.getPointByXOffset(placement);
      PVector lower_point = this.lower_edge.getPointByXOffset(placement);
      line(upper_point.x, upper_point.y, lower_point.x, lower_point.y);
    }
  }
}
