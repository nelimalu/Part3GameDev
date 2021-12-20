private boolean speedUp = false;
private int xPos = 150;
private int yPos = HEIGHT - 50;
private int speed_radius = 30;
private PVector[] wattles = {new PVector(70, 60), new PVector(70, 480)};

PImage[] balloonImages = new PImage[6];
PImage[] moabImages = new PImage[3];
PImage pop;
PImage wattle;

void loadBalloons() {
  String[] colours = {"red", "green", "yellow", "pink", "blue", "black"};
  
  for (int i = 0; i < colours.length; i++) {
    balloonImages[i] = loadImage(colours[i] + "Balloon.png");
  }
}

void loadMoabs() {
  String[] colours = {"blue", "red", "green"};
  
  for (int i = 0; i < colours.length; i++) {
    moabImages[i] = loadImage(colours[i] + "Moab.png");
  }
}

void loadPop() {
  pop = loadImage("pop.png");
  wattle = loadImage("wattle.png");
  wattle.resize(0, 100);
}

void drawWattles() {
  for (PVector location : wattles) {
    imageMode(CENTER);
    image(wattle, location.x, location.y);
    noFill();
  }
}

double getDistance(int x1, int y1, int x2, int y2) {
  return sqrt(pow(abs(x2 - x1), 2) + pow(abs(y2 - y1), 2));
}

void handleSpeedUpButton() {
  if (getDistance(mouseX, mouseY, xPos, yPos) <= speed_radius) {
    speedUp = !speedUp;
    if (speedUp)
      frameRate(120);
    else
      frameRate(60);
  }
}

void drawSpeedUpButton() {
  
  fill(#008B8B);
  if (playingLevel)
    circle(xPos, yPos, speed_radius + 24);
  else
    circle(xPos, yPos, speed_radius);
  fill(255);
  
  if (speedUp)
    text("2x", xPos - 9, yPos + 3);
  else
    text("1x", xPos - 9, yPos + 3);
}
