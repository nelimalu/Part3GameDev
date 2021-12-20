/** All powerups including
 *  - Path spikes
 *  - Slow Time
 *  - Damage/Speed boost for towers
 */
 
int powerupCount[] = {5, 3, 3}; // Amount of each powerup remaining
final int spikes = 0, slowdown = 1, speedboost = 2;
final int spikePierce = 3; // Amount of balloons the cluster of spikes will pop before disappearing

final int slowdownLength = 7; // Amount of time that a slowdown session lasts for in seconds
final int speedBoostLength = 7; // Amount of time that a speed boost session lasts for in seconds

float slowdownAmount = 1; // The factor to multiply all balloon speeds by
int slowdownRemaining = 0;
final PVector slowdownLocation = new PVector(763, 208); 

float speedBoostAmount = 1; // Factor to multiply all tower cooldowns by
int speedBoostRemaining = 0;
final PVector speedBoostLocation = new PVector(763, 258); 

PImage spikeIcon; // Image for path spikes
PVector spikeLocation = new PVector(763, 150); // Location of spike for drag and drop
ArrayList<PVector> spikeLocations;
ArrayList<Integer> spikeData;

final PVector originalSpikeLocation = new PVector(763, 150);

boolean spikeHeld = false;

/** Reimplementation of Drag and Drop for path spikes **/
boolean withinSpikeBounds() {
  return pointRectCollision(mouseX, mouseY, spikeLocation.x, spikeLocation.y, 45);
}

boolean spikeTrashDrop() {
  PVector location = spikeLocation;
  if (location.x >= trashX1 && location.x <= trashX2 && location.y >= trashY1 && location.y <= trashY2) return true;
  return false;
}

void handleSpikePickUp() {
  if (withinSpikeBounds() && powerupCount[spikes] > 0) {
    spikeHeld = true;
    
    PVector location = spikeLocation;
    difX = (int) location.x - mouseX; // Calculate the offset values (the mouse pointer may not be in the direct centre of the tower)
    difY = (int) location.y - mouseY;
  }
}

void handleSpikeDrop() {
  if (spikeTrashDrop()) {
    spikeLocation = originalSpikeLocation;
    println("Spike object in trash.");
  } else if (legalSpikeDrop()) {
    powerupCount[spikes]--; // Decrease remaining spikes by 1
    
    spikeLocations.add(spikeLocation.copy());
    spikeData.add(spikePierce);
    spikeLocation = originalSpikeLocation;
    println("Spike Dropped on Path");
  }
  spikeHeld = false;
}

void loadSpikeIcon() {
  spikeIcon = loadImage("spikes.png");
}
 
void drawSpikeIcon(PVector location, color colour) {
  ellipseMode(RADIUS);
  fill(colour);
  ellipse(location.x, location.y, 20, 20);
  
  imageMode(CENTER);
  image(spikeIcon, location.x, location.y);
}

void drawSpikeIcon(PVector location) {
  imageMode(CENTER);
  image(spikeIcon, location.x, location.y);
}

void drawAllSpikes() {
  for (int i = 0; i < spikeLocations.size(); i++) {
    if (spikeData.get(i) <= 0) {
      spikeData.remove(i);
      spikeLocations.remove(i);
      i--;
    }
    else {
      drawSpikeIcon(spikeLocations.get(i));
    }
  }
}

void drawCurrentSpikeIcon() {
  if (legalSpikeDrop() || spikeLocation.equals(originalSpikeLocation)) {
    drawSpikeIcon(spikeLocation, #FFFFFF);
  }
  else {
    drawSpikeIcon(spikeLocation, #F00000);
  }
}

boolean balloonSpikeCollision(PVector position) {
  for (int i = 0; i < spikeLocations.size(); i++) {
    PVector spikeLocation = spikeLocations.get(i);
    if (dist(position.x, position.y, spikeLocation.x, spikeLocation.y) <= PATH_RADIUS) {
      spikeData.set(i, spikeData.get(i) - 1);
      return true; // // Spike has popped the balloon!
    }
  }
  return false;
}

void displayPowerups() {
  fill(255);
  text("Slowdowns: " + powerupCount[slowdown], 642, 213);
  text("Speed Boosts: " + powerupCount[speedboost], 628, 263);
  
  color displayColour;
  
  /** Slowdown */
  if (mousePressed && withinSlowdownBounds() && powerupCount[slowdown] <= 0 && slowdownRemaining <= 0) {
    displayColour = #F00000; // Display using red error colour
  }
  else if (slowdownRemaining > 0) {
    displayColour = #81E5FF; // Display blue colour for slowdown in progress
  }
  else {
    displayColour = #FFFFFF; // Display using white colour
  }
  
  fill(displayColour);
  ellipseMode(RADIUS);
  
  ellipse(slowdownLocation.x, slowdownLocation.y, 20, 20);
  
  
  /** Speed Boosts */
  if (mousePressed && withinSpeedBoostBounds() && powerupCount[speedboost] <= 0 && speedBoostRemaining <= 0) {
    displayColour = #F00000; // Display using red error colour
  }
  else if (speedBoostRemaining > 0) {
    displayColour = #81E5FF; // Display blue colour for slowdown in progress
  }
  else {
    displayColour = #FFFFFF; // Display using white colour
  }
  fill(displayColour);
  ellipse(speedBoostLocation.x, speedBoostLocation.y, 20, 20);
  
  /** Spikes */
  if (mousePressed && withinSpikeBounds() && powerupCount[spikes] <= 0) {
    displayColour = #F00000; // Display using red error colour
  }
  else {
    displayColour = #FFFFFF; // Display using white colour
  }
  
  fill(displayColour);
  
  text("Spikes: " + powerupCount[spikes], 675, 150);
  drawSpikeIcon(originalSpikeLocation, displayColour);
}

boolean withinSlowdownBounds() {
  return pointRectCollision(mouseX, mouseY, slowdownLocation.x, slowdownLocation.y, 45);
}

void handleSlowdownPress() {
  if (withinSlowdownBounds() && powerupCount[slowdown] > 0 && slowdownAmount == 1) {
    powerupCount[slowdown]--;
    slowdownAmount = 0.5;
    slowdownRemaining = slowdownLength * 60;
  }
}

void handleSlowdown() {
  if (slowdownRemaining > 0) {
    slowdownRemaining--;
    
    if (slowdownRemaining == 0) {
      slowdownAmount = 1; // Revert to original speed
    }
  }
}

/** Speed Boost Powerup */

boolean withinSpeedBoostBounds() {
  return pointRectCollision(mouseX, mouseY, speedBoostLocation.x, speedBoostLocation.y, 45);
}

void handleSpeedBoostPress() {
  if (withinSpeedBoostBounds() && powerupCount[speedboost] > 0 && speedBoostAmount == 1) {
    powerupCount[speedboost]--;
    speedBoostAmount = 0.4;
    speedBoostRemaining = speedBoostLength * 60;
  }
}

void handleSpeedBoost() {
  if (speedBoostRemaining > 0) {
    speedBoostRemaining--;
    
    if (speedBoostRemaining == 0) {
      speedBoostAmount = 1; // Revert to original speed
    }
  }
}
