/*
Encompasses: Displaying Towers, Drag & Drop, Discarding Towers, Rotating Towers, Tower Validity Checking
 */
// -------- CODE FOR DRAG & DROP ----------------------

int currentlyDragging = -1; // -1 = not holding any tower, 0 = within default, 1 = within eight, 2 = within slow
final int notDragging = -1;
final int def = 0, eight = 1, slow = 2;
final int towerCount = 3;
int difX, difY, count, towerClicked = -1;

boolean[] held = {false, false, false};
int[] towerPrice = {100, 200, 200};
color[] towerColours = {#7b9d32, #F098D7, #82E5F7};
PVector[] originalLocations = {new PVector(650, 50), new PVector(700, 50), new PVector(750, 50)}; // Constant, "copy" array to store where the towers are supposed to be
PVector[] dragAndDropLocations = {new PVector(650, 50), new PVector(700, 50), new PVector(750, 50)}; // Where the currently dragged towers are

ArrayList<PVector> towers; // Towers that are placed down


final int towerSize = 25;
final color towerErrorColour = #E30707; // Colour to display when user purchases tower without sufficient funds
//final color 
//these variables are the trash bin coordinates
int trashX1, trashY1, trashX2, trashY2;

void initDragAndDrop() {
  difX = 0;
  difY = 0;

  trashX1 = 540;
  trashY1 = 10;
  trashX2 = trashX1 + 250;
  trashY2 = trashY1 + 90;

  count = 0;
  towers = new ArrayList<PVector>();
  towerData = new ArrayList<int[]>();
  spikeLocations = new ArrayList<PVector>();
  spikeData = new ArrayList<Integer>();
}

// Use point to rectangle collision detection to check for mouse being within bounds of pick-up box
boolean pointRectCollision(float x1, float y1, float x2, float y2, float size) {
  //            --X Distance--               --Y Distance--
  return (abs(x2 - x1) <= size / 2) && (abs(y2 - y1) <= size / 2);
}

boolean withinBounds(int towerID) {
  PVector towerLocation = dragAndDropLocations[towerID];
  return pointRectCollision(mouseX, mouseY, towerLocation.x, towerLocation.y, towerSize);
}

//check if you drop in trash
boolean trashDrop(int towerID) {
  PVector location = dragAndDropLocations[towerID];
  if (location.x >= trashX1 && location.x <= trashX2 && location.y >= trashY1 && location.y <= trashY2) return true;
  return false;
}

// -------Methods Used for further interaction-------
void handleDrop(int towerID) { // Will be called whenever a tower is placed down
  // Instructions to check for valid drop area will go here
  if (trashDrop(towerID)) {
    dragAndDropLocations[towerID] = originalLocations[towerID];
    held[towerID] = false;
    println("Dropped object in trash.");
  } else if (legalDrop(towerID)) {
    towers.add(dragAndDropLocations[towerID].copy());
    towerData.add(makeTowerData(towerID));
    dragAndDropLocations[towerID] = originalLocations[towerID];
    held[towerID] = false;
    purchaseTower(towerPrice[towerID]);
    println("Dropped for the " + (++count) + "th time.");
  }
}

// Will be called whenever a tower is picked up
void handlePickUp(int pickedUpTowerID) {
  if (withinBounds(pickedUpTowerID) && hasSufficientFunds(towerPrice[pickedUpTowerID])) {
    currentlyDragging = pickedUpTowerID;
    held[currentlyDragging] = true;
    PVector location = dragAndDropLocations[pickedUpTowerID];
    difX = (int) location.x - mouseX; // Calculate the offset values (the mouse pointer may not be in the direct centre of the tower)
    difY = (int) location.y - mouseY;
  }
  println("Object picked up.");
}

void drawTrash() {
  rectMode(CORNERS);
  noStroke();
  fill(#4C6710);
  rect(trashX1, trashY1, trashX2, trashY2);
  fill(255, 255, 255);
  stroke(255, 255, 255);
}

void dragAndDropInstructions() {
  fill(#4C6710);
  textSize(12);

  text("Pick up tower from here!", 620, 20);
  text("You can't place towers on the path of the balloons!", 200, 20);
  text("Place a tower into the surrounding area to put it in the trash.", 200, 40);
  text("Mouse X: " + mouseX + "\nMouse Y: " + mouseY + "\nMouse held: " + mousePressed + "\nTower Held: " + currentlyDragging + "\ntowerClicked: " + towerClicked, 15, 20);
}


// -------- CODE FOR PATH COLLISION DETECTION ---------

float pointDistToLine(PVector start, PVector end, PVector point) {
  // Code from https://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment
  float l2 = (start.x - end.x) * (start.x - end.x) + (start.y - end.y) * (start.y - end.y);  // i.e. |w-v|^2 -  avoid a sqrt
  if (l2 == 0.0) return dist(end.x, end.y, point.x, point.y);   // v == w case
  float t = max(0, min(1, PVector.sub(point, start).dot(PVector.sub(end, start)) / l2));
  PVector projection = PVector.add(start, PVector.mult(PVector.sub(end, start), t));  // Projection falls on the segment
  return dist(point.x, point.y, projection.x, projection.y);
}

float pointDistToArc(PVector start, PVector center, PVector end, PVector arcData, PVector point){
  if (abs(arcData.y) < radians(360)){
    float[] towerAngles = new float[2];
    towerAngles[0] = atan2(point.y-center.y,point.x-center.x) - arcData.x;
    
    if (towerAngles[0] < 0){
      towerAngles[1] = towerAngles[0] + radians(360);
    }
    else if(towerAngles[0] > 0){
      towerAngles[1] = towerAngles[0] - radians(360);
    }else{
      towerAngles[1] = 0;
    }
    
    for (float towerAngle: towerAngles){
      float t = towerAngle/arcData.y;
      if (t >= 0 && t <= 1){
        return abs(dist(point.x,point.y,center.x,center.y)-arcData.z);
      }
    }
  }
  return min(dist(point.x,point.y,start.x,start.y),dist(point.x,point.y,end.x,end.y));
}

float shortestDist(PVector point) {
  float answer = Float.MAX_VALUE;
  float distance = Float.MAX_VALUE;
  for (int i = 0; i < pathSegments.size(); i++) {
    ArrayList<PVector> pathSegment = pathSegments.get(i);

    if (pathSegment.size() == 2){
      PVector startPoint = pathSegment.get(start);
      PVector endPoint = pathSegment.get(end);
      distance = pointDistToLine(startPoint, endPoint, point);
    }else{
      PVector centerPoint = pathSegment.get(centerArc);
      PVector arcData = pathSegment.get(arcValues);
      if(dist(point.x,point.y,centerPoint.x,centerPoint.y) < arcData.z + 30){
        PVector startPoint = pathSegment.get(startArc);
        PVector endPoint = pathSegment.get(endArc);
        distance = pointDistToArc(startPoint, centerPoint, endPoint,arcData, point);
      }
    }
    answer = min(answer, distance);
  }
  return answer;
}

// Will return if a drop is legal by looking at the shortest distance between the rectangle center and the path.
boolean legalDrop(int towerID) {
  PVector heldLocation = dragAndDropLocations[towerID];
  // checking if this tower overlaps any of the already placed towers
  for (int i = 0; i < towers.size(); i++) {
    PVector towerLocation = towers.get(i);
    if (pointRectCollision(heldLocation.x, heldLocation.y, towerLocation.x, towerLocation.y, towerSize)) return false;
  }
  return shortestDist(heldLocation) > PATH_RADIUS;
}


// Checks if the location of the spike is on the path
boolean legalSpikeDrop() {
  PVector heldLocation = spikeLocation;
  return shortestDist(heldLocation) <= PATH_RADIUS;
}
