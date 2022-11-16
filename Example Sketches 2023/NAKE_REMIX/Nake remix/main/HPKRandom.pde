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