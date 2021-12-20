/*
Encompasses: Displaying Balloons, Waves & Sending Balloons, Balloon Reaching End of Path
*/

ArrayList<ArrayList<float[]>> levels = new ArrayList<ArrayList<float[]>>();
ArrayList<float[]> balloons;
final int distanceTravelled = 0, delay = 1, speed = 2, maxHP = 3, hp = 4, slowed = 5, ID = 6;
final int balloonRadius = 25; //Radius of the balloon

int levelNum = -1;
boolean playingLevel = false;

void drawBalloon(PImage image, float x, float y) {
  imageMode(CENTER);
  image(image, x, y);
  noFill();
}

void drawMoab(PImage image, float x, float y, float distanceTravelled) {
  pushMatrix();
  translate(x, y);
  
  PVector nextPos = getLocation(distanceTravelled + 1);
  float slope = (nextPos.y - y) / abs(nextPos.x - x);
  float angle = atan(slope);
  if (nextPos.x < x) {
    angle += radians(180);
    angle *= -1;
  }
  angle %= radians(360);
  

  rotate(angle);
  println(slope);
  
  image.resize(0, 80);
  strokeWeight(0);
  imageMode(CENTER);
  image(image, 0, 0);
  noFill();

  popMatrix();
  rotate(0);
}

float rangeMap(float value, float inMin, float inMax, float outMin, float outMax) {
  float inRange = inMax - inMin;
  float outRange = outMax - outMin;
  float percentDone = value / inRange;
  float outPercentDone = outRange * percentDone;
  return outPercentDone + outMin;
}

void createWaves() {
  createLevels(3);
  
  //(level balloons are for, number of balloons, first balloon delay, delay between the sequence of balloons, speed, hp, moabType)
  createBalloons(0,10,0,20,5,30,0);
  createBalloons(0,10,500,50,1,150,0);
  createBalloons(1,1,100,50,0.4,600,1);
  
  createBalloons(1,3,100,50,0.4,600,1);
  createBalloons(1,10,500,50,1,150,0);
  createBalloons(1,1,100,50,0.4,600,2);
  
  createBalloons(2,3,100,50,0.4,600,1);
  createBalloons(2,10,500,50,1,150,0);
  createBalloons(2,1,100,50,0.3,1000,2);
  createBalloons(2,1,100,50,0.2,2000,3);
  
  
  /*
  createBalloons(0,5,0,20,1,20,0);
  createBalloons(0,100,30,20,2,60,0);
  createBalloons(0,1,2300,0,0.6,1000,0);
  createBalloons(1,5,0,20,1,100,0);
  */
}

void createLevels(int num){
  for (int i = 0; i < num; i++){
    levels.add(new ArrayList<float[]>());
  }
}

void createBalloons(int level, int numBalloons, float delay, float delayInBetween, float speed, float hp, int moabType){
  for (int i = 0; i < numBalloons; i++){
    levels.get(level).add(new float[]{0, delay + i * delayInBetween, speed, hp, hp, 0, levels.get(level).size(), moabType});
  }
}

// Displays and moves balloons
void updatePositions(float[] balloon) {
  // Only when balloonProps[1] is 0 (the delay) will the balloons start moving.
  if (balloon[delay] < 0) {
    PVector position = getLocation(balloon[distanceTravelled]);
    float travelSpeed = balloon[speed] * slowdownAmount; // Slow down the balloon if the slowdown powerup is engaged
    balloon[distanceTravelled] += travelSpeed; //Increases the balloon's total steps by the speed

    //Drawing of balloon
    
    float healthPercent = balloon[4] / balloon[3];
    
    if (balloon[7] == 0) {
      float mapRange = 5 * healthPercent;
      println(mapRange);
      int colour = parseInt(mapRange);
      if (colour < 0) {
        colour = 0;
      }
      drawBalloon(balloonImages[colour], position.x, position.y);
    } else if (balloon[7] > 0) {
      drawMoab(moabImages[parseInt(balloon[7] - 1)], position.x, position.y, balloon[distanceTravelled]);
    }

    ellipseMode(CENTER);
    strokeWeight(0);
    stroke(0);
    fill(0);
    
    //draw healthbar outline
    stroke(0, 0, 0);
    strokeWeight(0);
    rectMode(CORNER);
    fill(#830000);
    final float hbLength = 35, hbWidth = 6;
    rect(position.x - hbLength / 2, position.y - (balloonRadius), hbLength, hbWidth);
    //draw mini healthbar
    noStroke();
    fill(#FF3131);
    rect(position.x - hbLength / 2, position.y - (balloonRadius), hbLength * (balloon[hp] / balloon[maxHP]), hbWidth); //the healthbar that changes based on hp
 
    noFill();
    
  
    //write text
    stroke(0, 0, 0);
    textSize(14);
    fill(255, 255, 255);
    text("Health: "+health, 670, 570);
    
    fill(#f3cd64);
    if (balloon[slowed] == 1) {
      fill(#C19D40);
    }
    // ellipse(position.x, position.y, balloonRadius, balloonRadius);

  } else {
    balloon[delay]-=balloon[speed];
  }
}

void drawBalloons() {
  balloons = levels.get(levelNum);
  for (int i = 0; i < balloons.size(); i++) {
    float[] balloon = balloons.get(i);
    updatePositions(balloon);

    PVector position = getLocation(balloon[distanceTravelled]);
    if (balloonSpikeCollision(position) || balloon[hp] <= 0) {
      if (balloons.get(i)[7] > 0) {
        for (int j = 0; j < balloons.get(i)[7] * 10; j++)
          balloons.add(new float[]{balloons.get(i)[0], 0, random(3) + 0.2, 20, 20, 0, 0, 0});
      } else {
        drawBalloon(pop, position.x, position.y);
      }
      
      handleBalloonPop();
      balloons.remove(i);
      i--;
      
      continue;
    }
    if (balloon[distanceTravelled] >= pathLength) {
      balloons.remove(i); // Removing the balloon from the list
      if (balloon[7] > 0) {
        health -= balloon[7];
      }
      health--; // Lost a life.
      i--; // Must decrease this counter variable, since the "next" balloon would be skipped
      // When you remove a balloon from the list, all the indexes of the balloons "higher-up" in the list will decrement by 1
    }
  }
  if (balloons.size() == 0 && playingLevel){
    playingLevel = false;
    handleWaveReward(levelNum + 1);
  }
}

// ------- HP SYSTEM --------
/*
  Heath-related variables:
 int health: The player's total health.
 This number decreases if balloons pass the end of the path (offscreen), currentely 11 since there are 11 balloons.
 PImage heart: the heart icon to display with the healthbar.
 */
int health = 11;  //variable to track user's health
PImage heart;

void loadHeartIcon() {
  heart = loadImage("heart.png");
}
//method to draw a healthbar at the bottom right of the screen
void drawHealthBar() {
  //draw healthbar outline
  stroke(0, 0, 0);
  strokeWeight(0);
  fill(#830000);
  rectMode(CENTER);
  rect(721, HEIGHT - 35, 132, 20);
  int trueHealth = max(health, 0);
  //draw healthbar
  noStroke();
  rectMode(CORNER);
  fill(#FF3131);
  rect(655, HEIGHT - 45, trueHealth*12, 20); //the healthbar that changes based on hp
  rectMode(CENTER);
  noFill();

  //write text
  stroke(0, 0, 0);
  textSize(14);
  fill(255, 255, 255);
  text("Health:   " + trueHealth, 670, HEIGHT - 30);

  //put the heart.png image on screen
  imageMode(CENTER);
  image(heart, 650, HEIGHT - 33);
  noFill();
}

//Next level Button
boolean pointRectCollision(float x1, float y1, float x2, float y2, float sizeX, float sizeY) {
  //            --X Distance--               --Y Distance--
  return (abs(x2 - x1) <= sizeX / 2) && (abs(y2 - y1) <= sizeY / 2);
}

void handleNextLevel() {
  PVector center = new PVector(60,HEIGHT - 50);
  PVector lengths = new PVector(100,100);
  if (!playingLevel && pointRectCollision(mouseX,mouseY,center.x,center.y,lengths.x,lengths.y) && levelNum < levels.size()-1){
    playingLevel = true;
    levelNum++;
  }
}
void drawNextLevelButton(){
  PVector center = new PVector(60,HEIGHT - 50);
  PVector lengths = new PVector(100,70);
  
  fill(0,150,0);
  if (playingLevel){ 
    fill(0,150,0,100);
  }
  
  rect(center.x,center.y,lengths.x,lengths.y, 10);
  fill(255);
  
  text("Next Level", center.x - 35, center.y + 4);
  
}
