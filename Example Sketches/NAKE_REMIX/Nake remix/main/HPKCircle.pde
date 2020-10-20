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
