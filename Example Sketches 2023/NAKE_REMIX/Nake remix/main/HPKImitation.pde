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
