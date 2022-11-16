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
