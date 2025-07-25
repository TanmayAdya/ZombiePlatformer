public class Enemy extends AnimatedSprite{
  float boundaryLeft, boundaryRight;
  public Enemy(PImage img, float scale, float bLeft, float bRight) {
    super(img, scale);
    moveLeft = new PImage[2];
    moveLeft[0] = loadImage("slime_walk_left1.png");
    moveLeft[1] = loadImage("slime_walk_left2.png");
    moveRight = new PImage[2];
    moveRight[0] = loadImage("slime_walk_right1.png");
    moveRight[1] = loadImage("slime_walk_right2.png"); 
    currentImages = moveRight;
    direction = RIGHT_FACING;
    boundaryLeft = bLeft;
    boundaryRight = bRight;
    change_x = 2;
  }
  void update() {
    // call update of Sprite(super)
    super.update();
    if(getLeft() <= boundaryLeft) {
      setLeft(boundaryLeft);
      change_x *= -1;
    } else if(getRight() >= boundaryRight) {
      setRight(boundaryRight);
      change_x *= -1;
    }
    // if right side of spider >= right boundary
    //   fix by setting right side of spider to equal right boundary
    //   then change x-direction 
    // else if left side of spider <= left boundary
    //   fix by setting lfet side of spider to equal left boundary
    //   then change x-direction 
  }
}
