import processing.sound.*;

final static float MOVE_SPEED = 4;
final static float SPRITE_SCALE = 50.0/128;
final static float SPRITE_SIZE = 50;
final static float GRAVITY = .6;
final static float JUMP_SPEED = 14; 

final static float RIGHT_MARGIN = 400;
final static float LEFT_MARGIN = 60;
final static float VERTICAL_MARGIN = 40;

final static float WIDTH = SPRITE_SIZE * 16;
final static float HEIGHT = SPRITE_SIZE * 12;
final static float GROUND_LEVEL = HEIGHT - SPRITE_SIZE;

final static int NEUTRAL_FACING = 0; 
final static int RIGHT_FACING = 1; 
final static int LEFT_FACING = 2; 

final static float BRAIN_SCALE = 0.4;

Player player;
PImage nFloor, nFloorLeft, nFloorRight, nFloorRound;
PImage inAirPlatform, inAirPlatformLeft, inAirPlatformRight, inAirPlatformRound;
PImage crossBox, blueGlass;
PImage playerImage;
PImage brain, slime, honey;
PImage portal, portalButton, portalButton2;
PImage speedArrow, speedRight, speedLeft, speed;
PImage finalDone;
PFont startFont, endFont, finishFont, introFont;
ArrayList<Sprite> platforms, fastPlatforms, slowPlatforms;
ArrayList<Sprite> portals, enemies, speedArrows;
ArrayList<Sprite> brains, finish;
SoundFile song;

boolean isGameOver;
boolean buttonOver = false;
int score;
float view_x;
float view_y;


void setup() {
  size(1000, 600);
  imageMode(CENTER);
  
  song = new SoundFile(this, "backgroundM.mp3");
  song.loop();
  song.amp(0.5);
  
  playerImage = loadImage("player_stand_right.png");
  player = new Player(playerImage, 0.8);
  player.center_x = 100;
  player.center_y = 100;
  
  //Initialize all arrays!
  platforms = new ArrayList<Sprite>();
  slowPlatforms = new ArrayList<Sprite>();
  fastPlatforms = new ArrayList<Sprite>();
  brains = new ArrayList<Sprite>();
  portals = new ArrayList<Sprite>();
  enemies = new ArrayList<Sprite>();
  finish = new ArrayList<Sprite>();
  speedArrows = new ArrayList<Sprite>();
  
  //Set brain count to 0 and the game is not over!
  score = 0;
  isGameOver = false;
  
  //Initialize all images and the csv!
  speedArrow = loadImage("speedArrow.png");
  speed = loadImage("speed.png");
  speedRight = loadImage("speedRight.png");
  speedLeft = loadImage("speedLeft.png");
  finalDone = loadImage("finalDone.png");
  portalButton2 = loadImage("portalButton2.png");
  portalButton = loadImage("portalButton.png");
  portal = loadImage("portal.png");
  honey = loadImage("honey.png");
  brain = loadImage("brain.png");
  slime = loadImage("slime_walk_right1.png");
  crossBox = loadImage("crossBox.png");
  blueGlass = loadImage("blueGlass.png");
  inAirPlatform = loadImage("inAirPlatform.png");
  inAirPlatformLeft = loadImage("inAirPlatformLeft.png");
  inAirPlatformRight = loadImage("inAirPlatformRight.png");
  inAirPlatformRound = loadImage("inAirPlatformRound.png");
  nFloor = loadImage("nFloor.png");
  nFloorLeft = loadImage("nFloorLeft.png");
  nFloorRight = loadImage("nFloorRight.png");
  nFloorRound = loadImage("nFloorRound.png");
  createPlatforms("map.csv");
  
  //Set view to 0!
  view_x = 0;
  view_y = 0;
  
  //Create different fonts!
  startFont = createFont("ZombieFont.otf", 32);
  endFont = createFont("GameEndingFont.ttf", 64);
  finishFont = createFont("GameEndingFont.ttf", 32);
  introFont = createFont("introFont.ttf", 32);
}

void draw() {
  //Set background color!
  background(115);
  
  //Call scroll!
  scroll();
  
  //Display everything!
  displayAll();
  
  //Show portal button!
  image(portalButton, 1375, 400, portalButton.width * SPRITE_SCALE, portalButton.height * SPRITE_SCALE);
  
  //If the game is NOT over, update everything
  //Check if any brains have been collected
  //Check if player has lost a life!
  if(!isGameOver) {
    updateAll();
    collectBrains();
    checkDeath();
  }
  
  //Update is a button method!
  //The if-else uses the knowledge that the mouse is over the button
  //to then change the image while the mouse is hovering ober the button!
  update(mouseX + (int)view_x, mouseY + (int)view_y);
  if (buttonOver) {
    portalButton = portalButton2;
  } else {
    portalButton = loadImage("portalButton.png");
  }
  
  //Allows player to move from first portal to the second portal! ONLY IF BRAINS >= 7
  if(isOnPlatforms(player, portals) && view_x < portals.get(0).getRight() && score >=7) {
    player.center_x = portals.get(1).center_x;
   player.center_y = portals.get(1).center_y;
 }
}

//Updates if the mouse is over the button and the diameter!
void update(int x, int y) {
  if (overButton(1375, 400, 95 * SPRITE_SCALE)) {
    buttonOver = true;
  } else {
    buttonOver = false;
  }
}

//If the mouse is pressed and over the button
//it will move the player from second portal to first and 
//ONLY if BRAINS >= 7!
void mousePressed() {
  if (buttonOver) {
    if(isOnPlatforms(player, portals) && score >= 7) {
      player.center_x = portals.get(0).center_x - 100;
      player.center_y = portals.get(0).center_y;
    }
  }
}

//This checks if just the mouse is hovering over the button!
boolean overButton(int x, int y, float diameter) {
  float disX = x - mouseX - view_x;
  float disY = y - mouseY - view_y;
  if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  } else {
    return false;
  }
}

//Displays everything!
void displayAll() {
  for(Sprite s: platforms) {
    s.display();
  }
  for(Sprite c: brains) {
    c.display();
  }
  for(Sprite s: fastPlatforms) {
    s.display();
  }
  for(Sprite s: slowPlatforms) {
    s.display();
  }
  for(Sprite s: portals) {
    s.display();
  }
  for(Sprite s: speedArrows) {
    s.display();
  }
  for(Sprite s: enemies) {
    s.display();
  }
  for(Sprite s: finish) {
    s.display();
  }
  player.display();
  
  //This shows all the text and scores!
  fill(44, 203, 115);
  textFont(startFont);
  text("Brains:" + score, view_x + 50, view_y + 50);
  text("Lives:" + player.lives, view_x + 50, view_y + 100);
  textFont(endFont);
  
  if(isGameOver) {
    fill(0, 0, 255);
    background(255);
    textAlign(CENTER);
    text("GAME OVER!", view_x + width/2, view_y + height/2);
    if (player.lives == 0) {
      fill(255, 0, 0);
      text("You lose!", view_x + width/2, view_y + height/2 + 75);
    } else {
      fill(0, 255, 0);
      text("You win!", view_x + width/2, view_y + height/2 + 75);
    }
    fill(0, 0, 255);
    text("Press SPACE to restart!", view_x + width/2, view_y + height/2 + 150);
  }
}

//Updates everything!
void updateAll() {
  player.updateAnimation();
  resolvePlatformCollisions(player, platforms);
  for(Sprite e: enemies) {
    e.update();
    ((AnimatedSprite)e).updateAnimation();
  }
  for(Sprite c: brains) {
    ((AnimatedSprite)c).updateAnimation();
  }
  
  collectBrains();
}

//Checks if you have died!
void checkDeath() {
  boolean collideEnemy = false;
  for(Sprite e: enemies) {
    if (checkCollision(player, e)) {
      collideEnemy = true;
    }
  }
  
  boolean fallOffCliff = player.getBottom() > GROUND_LEVEL + 925;
  if(collideEnemy || fallOffCliff) {
    player.lives--;
    if(player.lives == 0) {
      isGameOver = true;
    } else {
      player.center_x = 100;
      player.setBottom(GROUND_LEVEL);
      view_x = 0;
      view_y = 0;
    }
  }
}

void collectBrains() {
  ArrayList<Sprite> brain_list = checkCollisionList(player, brains);
  if(brain_list.size() > 0) {
    for (Sprite brain: brain_list) {
      score++;
      brains.remove(brain);
    }
  }
  if(brains.size() == 0) {
    fill(255, 64, 64);
    textFont(finishFont);
    textAlign(LEFT);
    text("You still need to go to the finish light!", 200 + view_x, 150 + view_y);
    if(isOnPlatforms(player, finish)) {
    isGameOver = true;
    }
  }
}

void scroll() {
  float left_boundary = view_x + LEFT_MARGIN;
  if(player.getLeft() < left_boundary) {
   view_x -= left_boundary - player.getLeft(); 
  }
  
  float right_boundary = view_x + width - RIGHT_MARGIN;
  if(player.getRight() > right_boundary) {
   view_x += player.getRight() - right_boundary; 
  }
  
  float top_boundary = view_y + VERTICAL_MARGIN;
  if(player.getTop() < top_boundary) {
   view_y -= top_boundary - player.getTop(); 
  }
  
  float bottom_boundary = view_y + height - VERTICAL_MARGIN;
  if(player.getBottom() > bottom_boundary) {
   view_y += player.getBottom() - bottom_boundary; 
  }
  
  translate(-view_x, -view_y);
}


public boolean isOnPlatforms(Sprite s, ArrayList<Sprite> walls) {
  s.center_y += 5;
  ArrayList<Sprite> collision_list = checkCollisionList(s, walls);
  s.center_y -= 5;
  return collision_list.size() > 0; 
}

public void resolvePlatformCollisions(Sprite s, ArrayList<Sprite> walls) {
  s.change_y += GRAVITY;
  s.center_y += s.change_y;
  ArrayList<Sprite> col_list = checkCollisionList(s, walls);
  if(col_list.size() > 0) {
    Sprite collided = col_list.get(0);
    if(s.change_y > 0) {
      s.setBottom(collided.getTop());
    }
    else if(s.change_y < 0) {
      s.setTop(collided.getBottom());
    }
    s.change_y = 0;
  }

  s.center_x += s.change_x;
  col_list = checkCollisionList(s, walls);
  if(col_list.size() > 0) {
    Sprite collided = col_list.get(0);
    if(s.change_x > 0) {
        s.setRight(collided.getLeft());
    }
    else if(s.change_x < 0) {
        s.setLeft(collided.getRight());
    }
  }
}

boolean checkCollision(Sprite s1, Sprite s2) {
  boolean noXOverlap = s1.getRight() <= s2.getLeft() || s1.getLeft() >= s2.getRight();
  boolean noYOverlap = s1.getBottom() <= s2.getTop() || s1.getTop() >= s2.getBottom();
  if(noXOverlap || noYOverlap) {
    return false;
  } else {
    return true;
  }
}

public ArrayList<Sprite> checkCollisionList(Sprite s, ArrayList<Sprite> list) {
  ArrayList<Sprite> collision_list = new ArrayList<Sprite>();
  for(Sprite p: list) {
    if(checkCollision(s, p)) {
      collision_list.add(p);
    }
  }
  return collision_list;
}


void createPlatforms(String filename) {
  String[] lines = loadStrings(filename);
  for(int row = 0; row < lines.length; row++) {
    String[] values = split(lines[row], ",");
    for(int col = 0; col < values.length; col++) {
      if(values[col].equals("a")) {
        Sprite s = new Sprite(crossBox, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("b")) {
        Sprite s = new Sprite(nFloor, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("bL")) {
        Sprite s = new Sprite(nFloorLeft, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("bR")) {
        Sprite s = new Sprite(nFloorRight, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("br")) {
        Sprite s = new Sprite(nFloorRound, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("c")) {
        Sprite s = new Sprite(blueGlass, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("h")) {
        Sprite s = new Sprite(honey, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
        slowPlatforms.add(s);
      }
      else if(values[col].equals("d")) {
        Sprite s = new Sprite(inAirPlatform, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("dL")) {
        Sprite s = new Sprite(inAirPlatformLeft, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("dR")) {
        Sprite s = new Sprite(inAirPlatformRight, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("dr")) {
        Sprite s = new Sprite(inAirPlatformRound, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("s")) {
        Sprite s = new Sprite(speed, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
        fastPlatforms.add(s);
      }
      else if(values[col].equals("sL")) {
        Sprite s = new Sprite(speedLeft, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
        fastPlatforms.add(s);
      }
      else if(values[col].equals("sR")) {
        Sprite s = new Sprite(speedRight, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
        fastPlatforms.add(s);
      }
      else if(values[col].equals("sA")) {
        Sprite s = new Sprite(speedArrow, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        speedArrows.add(s);
      }
      else if(values[col].equals("p")) {
        Sprite s = new Sprite(portal, 0.6);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE - 20;
        portals.add(s);
      }
      else if(values[col].equals("e")) {
        Brain c1 = new Brain(brain, SPRITE_SCALE);
        c1.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        c1.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        brains.add(c1);
      }
      else if(values[col].equals("finish")) {
        Sprite s = new Sprite(finalDone, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        finish.add(s);
      }
      else if(values[col].equals("0")) {
        continue;
      }
      else{
        int lengthGap = int(values[col]);
        float bLeft = col * SPRITE_SIZE;
        float bRight = bLeft + lengthGap * SPRITE_SIZE;
        Enemy enemy = new Enemy(slime, 1, bLeft, bRight);
        enemy.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        enemy.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE + 8;
        enemies.add(enemy);
      }
    }
  }
}

void keyPressed() {
  if(keyCode == RIGHT) {
    if(isOnPlatforms(player, slowPlatforms)) {
      player.change_x = MOVE_SPEED - 3;
    } else if(isOnPlatforms(player, fastPlatforms)) {
      player.change_x = MOVE_SPEED + 3;
    } else {
      player.change_x = MOVE_SPEED;
    }
  }
  else if(keyCode == LEFT) {
    if(isOnPlatforms(player, slowPlatforms)) {
      player.change_x = -MOVE_SPEED + 3;
    } else if (isOnPlatforms(player, fastPlatforms)) {
      player.change_x = -MOVE_SPEED - 3;
    } else {
      player.change_x = -MOVE_SPEED;
    }
  }
  else if(keyCode == UP && isOnPlatforms(player, platforms)) {
    if(isOnPlatforms(player, slowPlatforms)) {
      player.change_y = -JUMP_SPEED + 3;
    } else if (isOnPlatforms(player, fastPlatforms)) {
      player.change_y = -JUMP_SPEED - 3;
    } else {
      player.change_y = -JUMP_SPEED;
    }
  }
  else if (isGameOver && key == ' ') {
    setup();
  }
}

void keyReleased() {
  if(keyCode == RIGHT) {
    player.change_x = 0;
  }
  else if(keyCode == LEFT) {
    player.change_x = 0;
  }
}
