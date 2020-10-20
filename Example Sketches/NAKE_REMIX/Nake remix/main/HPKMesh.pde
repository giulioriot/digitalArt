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
