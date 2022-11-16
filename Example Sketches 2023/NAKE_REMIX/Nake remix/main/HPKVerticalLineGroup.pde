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