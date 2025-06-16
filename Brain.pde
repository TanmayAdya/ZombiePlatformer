public class Brain extends AnimatedSprite{
  // call super appropriately
  // initialize standNeutral PImage array only since
  // we only have four brains and brains do not move.
  // set currentImages to point to standNeutral array(this class only cycles
  // through standNeutral for animation).
  public Brain(PImage img, float scale) {
    super(img, scale);
    standNeutral = new PImage[1];
    standNeutral[0] = loadImage("brain.png");
    currentImages = standNeutral;
  }
  
}
