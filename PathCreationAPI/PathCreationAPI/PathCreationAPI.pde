// This program is used to simulate picking up, dragging, and dropping objects

import java.util.ArrayList;
import java.util.List;
import java.util.HashSet;
// Program main method

int WIDTH = 800;
int HEIGHT = 600;
PVector[] grass = new PVector[50];
boolean mousedown = false;

void setup() {
  size(800, 600);
  frameRate(60);
  loadHeartIcon();
  loadSpikeIcon();
  loadBalloons();
  loadMoabs();
  loadPop();
  initDragAndDrop();
  initPath();
  createWaves();
  createGrass();
}

void draw() {
  background(#add558);
  drawGrass();
  drawPath();

  drawAllTowers(); // Draw all the towers that have been placed down before
  drawWattles();
  handleProjectiles();
  drawTrash();
  drawSelectedTowers();
  //dragAndDropInstructions();
  
  drawCurrentSpikeIcon();
  displayPowerups();
  drawAllSpikes();
  handleSlowdown();
  handleSpeedBoost();

  if (playingLevel){
    drawBalloons();
  }
  drawHealthBar();
  drawBalanceDisplay();
  drawSpeedUpButton();
  drawNextLevelButton();
  
  drawTowerUI();
  /*
  //upgrading towers implementation
  drawUpgrade();
  upgradeCheck();
  
  //removing towers implementation
  drawRemove();
  removeCheck();
  */
  
  towerClickCheck();
  drawRange();
  
  if (health <= 0) {
    drawLostAnimation();
  }
}

// Whenever the user drags the mouse, update the x and y values of the tower
void mouseDragged() {
  if (currentlyDragging != notDragging) {
    dragAndDropLocations[currentlyDragging] = new PVector(mouseX + difX, mouseY + difY);
  }
  if (spikeHeld) {
    spikeLocation = new PVector(mouseX + difX, mouseY + difY);
  }
}

// Whenever the user initially presses down on the mouse
void mousePressed() {
  mousedown = true;
  for (int i = 0; i < towerCount; i++) {
    handlePickUp(i);
  }
  handleSpikePickUp();
  handleSlowdownPress();
  handleSpeedBoostPress();
  handleNextLevel();
  handleSpeedUpButton();
}

// Whenever the user releases their mouse
void mouseReleased() {
  mousedown = false;
  if (currentlyDragging != notDragging) {
    handleDrop(currentlyDragging);
  }
  currentlyDragging = notDragging;
  
  if (spikeHeld) {
    handleSpikeDrop();
  }
}

void createGrass() {
  for (int i = 0; i < grass.length; i++) {
    int x = int(random(WIDTH));
    int y = int(random(HEIGHT));
    grass[i] = new PVector(x, y);
  }
  
}

void drawGrass() {
  int size = 3;
  for (int i = 0; i < grass.length; i++) {
    noFill();
    stroke(#4C6710);
    strokeWeight(1);
    ellipseMode(CENTER);
    
    line(grass[i].x, grass[i].y, grass[i].x, grass[i].y - size * 1.5);
    line(grass[i].x, grass[i].y, grass[i].x + size, grass[i].y - size);
    line(grass[i].x, grass[i].y, grass[i].x - size, grass[i].y - size);
  }
}
