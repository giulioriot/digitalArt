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
