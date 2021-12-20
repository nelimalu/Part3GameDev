/*
Encompasses: Displaying Towers & Tower Data (for projectiles)
*/

final int cooldownRemaining = 0, maxCooldown = 1, towerVision = 2, projectileType = 3, upgrade = 4;

ArrayList<int[]> towerData;
int[] towerVisions = {200, 100, 100};
int[] makeTowerData(int towerID) {  
  if (towerID == def) {
    return new int[] {
      10, // Cooldown between next projectile
      10, // Max cooldown
      towerVisions[def], // Tower Vision
      0, // Projectile ID
      1
    };
  } else if (towerID == eight) {
    return new int[] {
      25, // Cooldown between next projectile
      25, // Max cooldown
      towerVisions[eight], // Tower Vision
      1, // Projectile ID
      1
    };
  } else if (towerID == slow) {
    return new int[] {
      35,
      35,
      towerVisions[slow], // Tower Vision
      2,
      1
    };
  }
  return new int[] {}; //filler since we need to return something
}

// --------------------------------------------------

// Draw a simple tower at a specified location
void drawTowerIcon(float xPos, float yPos, color colour) {
  strokeWeight(0);
  stroke(0);
  fill(colour);
  rectMode(CENTER);
  rect(xPos, yPos, towerSize, towerSize); // Draw a simple rectangle as the tower
}

// Draws a tower that rotates to face the targetLocation
void drawTowerWithRotation(float xPos, float yPos, color colour, PVector targetLocation) {
  pushMatrix();
  translate(xPos, yPos);

  // Angle calculation
  float slope = (targetLocation.y - yPos) / (targetLocation.x - xPos);
  float angle = atan(slope);

  rotate(angle);

  strokeWeight(0);
  fill(colour);
  rectMode(CENTER);
  rect(0, 0, towerSize, towerSize); // Draw a simple rectangle as the tower

  popMatrix();
}

void drawAllTowers() {
  for (int i = 0; i < towers.size(); i++) {
    float xPos = towers.get(i).x, yPos = towers.get(i).y;
    int[] data = towerData.get(i);
    int towerType = data[projectileType];
    
    PVector track = null;
    if (playingLevel) {
      track = track(towers.get(i), data[towerVision]);
    }
    
    if (track == null) {
      drawTowerIcon(xPos, yPos, towerColours[towerType]);
    } 
    else {
      drawTowerWithRotation(xPos, yPos, towerColours[towerType], new PVector(track.x, track.y));
    }
    
    if(pointRectCollision(mouseX, mouseY, xPos, yPos, towerSize)) {
      // Drawing the tower range visually 
      fill(127, 80);
      stroke(127);
      strokeWeight(4);
      ellipseMode(RADIUS);
      ellipse(xPos, yPos, data[towerVision], data[towerVision]);
    }
    fill(#4C6710);
    textSize(12);
    text("Tower " + (i+1), xPos - 30, yPos - 20);
  }
}

void drawSelectedTowers() {
  // Draws the tower you're dragging
  // Changing the color if it is an illegal drop to red
  // Loops through the three towerIDs and checks each if any of them are currently being dragged
  // Note that more than one tower can be dragged at a time
  for (int towerID = 0; towerID < towerCount; towerID++) {
    if (held[towerID]) {
      PVector location = dragAndDropLocations[towerID];
      if (!legalDrop(towerID)) {
        drawTowerIcon(location.x, location.y, #FF0000);
      } else {
        drawTowerIcon(location.x, location.y, towerColours[towerID]);
      }
      // Drawing the tower range of the selected towers 
      fill(127, 80);
      stroke(127);
      strokeWeight(4);
      ellipseMode(RADIUS);
      ellipse(location.x, location.y, towerVisions[towerID], towerVisions[towerID]);
    }
  }
  // Draws the default towers
  for (int towerType = 0; towerType < towerCount; towerType++) {
    PVector location = originalLocations[towerType];
    if (attemptingToPurchaseTowerWithoutFunds(towerType)) {
      drawTowerIcon(location.x, location.y, towerErrorColour);
    } else drawTowerIcon(location.x, location.y, towerColours[towerType]);
    fill(255);
    textSize(14);
    int textOffsetX = -15, textOffsetY = 26;
    // displays the prices of towers
    text("$" + towerPrice[towerType], location.x + textOffsetX, location.y + textOffsetY);
  }
}
