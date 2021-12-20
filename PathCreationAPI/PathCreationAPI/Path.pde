/*
Encompasses: The Path for Balloons, Balloon Movement
 */

// ------- CODE FOR THE PATH
ArrayList<ArrayList<PVector>> pathSegments = new ArrayList<ArrayList<PVector>>();
final int start = 0, end = 1;
final int startArc = 0, centerArc = 1, endArc = 2, arcValues = 3;

final int PATH_RADIUS = 15;
float pathLength;

void initPoints() {
  //addDirectedLine(0,200,175,-radians(20));
  //addSuddenArc(75,radians(180));
  //addSmoothArc(100,radians(78));
  
  addDirectedLine(0, HEIGHT / 2, 100, radians(0));
  addSuddenArc(250,radians(180));
  addSmoothArc(195,radians(180));
  addSmoothArc(140,radians(180));
  addSmoothArc(55,radians(180));
  addSuddenArc(110, -radians(180));
  addSuddenArc(-83, -radians(180));
  addSmoothArc(-195, -radians(180));
  addSmoothArc(-250, -radians(180));
  addDirectedLine(662, (HEIGHT / 2) - 1, 135, radians(0));
 
}

void addLine(float startX, float startY, float endX, float endY){
  pathSegments.add(new ArrayList<PVector>());
  
  //If the line should continue from the existing path
  if (startX == -1 && startY == -1){
    ArrayList<PVector> pathSegment = pathSegments.get(pathSegments.size()-2);
    //If the previous path segment was a line
    if (pathSegment.size() == 2){
       startX = pathSegment.get(end).x;
       startY = pathSegment.get(end).y;
    }
    //If the previous path segment was an arc
    else{
       startX = pathSegment.get(endArc).x;
       startY = pathSegment.get(endArc).y;
    }
  }

  
  pathSegments.get(pathSegments.size()-1).add(new PVector(startX,startY));
  pathSegments.get(pathSegments.size()-1).add(new PVector(endX,endY));
}

void addArc(float x, float y, float centerX, float centerY, float displacementAngle){
  pathSegments.add(new ArrayList<PVector>());
  
  //If the line should continue from the existing path
  if (x == -1 && y == -1){
    ArrayList<PVector> pathSegment = pathSegments.get(pathSegments.size()-2);
    //If the previous path segment was a line
    if (pathSegment.size() == 2){
       x = pathSegment.get(end).x;
       y = pathSegment.get(end).y;
    }
    //If the previous path segment was an arc
    else{
       x = pathSegment.get(endArc).x;
       y = pathSegment.get(endArc).y;
    }
  }
  
  float startingAngle = atan2(y-centerY,x-centerX); //Starting angle
  float radius = dist(x,y,centerX,centerY); //radius of the arc
  float finalAngle = startingAngle + displacementAngle; //Angle that will determine where the end coordinates are for the arc
  
  pathSegments.get(pathSegments.size()-1).add(new PVector(x,y));
  pathSegments.get(pathSegments.size()-1).add(new PVector(centerX,centerY));
  pathSegments.get(pathSegments.size()-1).add(new PVector(centerX+radius*cos(finalAngle),centerY+radius*sin(finalAngle)));
  pathSegments.get(pathSegments.size()-1).add(new PVector(startingAngle,displacementAngle,radius));
}

void addSmoothArc(float distanceAway, float displacementAngle){
  PVector endPoint;
  PVector directionVector;
  ArrayList<PVector> pathSegment = pathSegments.get(pathSegments.size()-1);
  
  if (pathSegment.size() == 2){
    PVector startPoint = pathSegment.get(start);
    endPoint = pathSegment.get(end);
    
    float scaleFactor = dist(startPoint.x,startPoint.y,endPoint.x,endPoint.y);
    
    directionVector = new PVector(-(endPoint.y-startPoint.y)*distanceAway/scaleFactor, (endPoint.x-startPoint.x)*distanceAway/scaleFactor);
  }else{
    PVector centerPoint = pathSegment.get(centerArc);
    endPoint = pathSegment.get(endArc);
    
    float scaleFactor = dist(centerPoint.x,centerPoint.y,endPoint.x,endPoint.y) * pathSegment.get(arcValues).y/abs(pathSegment.get(arcValues).y);
    
    directionVector = new PVector((centerPoint.x-endPoint.x)*distanceAway/scaleFactor, (centerPoint.y-endPoint.y)*distanceAway/scaleFactor);
  }
  
  addArc(-1,-1, endPoint.x+directionVector.x, endPoint.y+directionVector.y, displacementAngle);
}

void addSmoothLine(int steps){
  ArrayList<PVector> pathSegment = pathSegments.get(pathSegments.size()-1);
  PVector centerPoint = pathSegment.get(centerArc);
  PVector endPoint = pathSegment.get(endArc);
       
  float scaleFactor = dist(centerPoint.x,centerPoint.y,endPoint.x,endPoint.y) * pathSegment.get(arcValues).y/abs(pathSegment.get(arcValues).y);
  PVector directionVector = new PVector(-(endPoint.y-centerPoint.y)/scaleFactor, (endPoint.x-centerPoint.x)/scaleFactor);
  directionVector = PVector.mult(directionVector, steps);
  
  addLine(-1, -1, endPoint.x+directionVector.x, endPoint.y+directionVector.y);
}

void addDirectedLine(float startX, float startY, float radius, float direction){
  pathSegments.add(new ArrayList<PVector>());
  
  //If the line should continue from the existing path
  if (startX == -1 && startY == -1){
    ArrayList<PVector> pathSegment = pathSegments.get(pathSegments.size()-2);
    //If the previous path segment was a line
    if (pathSegment.size() == 2){
       startX = pathSegment.get(end).x;
       startY = pathSegment.get(end).y;
    }
    //If the previous path segment was an arc
    else{
       startX = pathSegment.get(endArc).x;
       startY = pathSegment.get(endArc).y;
    }
  }
  
  float endX = startX + cos(direction)*radius;
  float endY = startY + sin(direction)*radius;
  
  pathSegments.get(pathSegments.size()-1).add(new PVector(startX,startY));
  pathSegments.get(pathSegments.size()-1).add(new PVector(endX,endY));
}

void addSuddenArc(float distanceAway, float angle){
  ArrayList<PVector> pathSegment = pathSegments.get(pathSegments.size()-1);
  
  PVector lineStart = pathSegment.get(start);
  PVector lineEnd = pathSegment.get(end);
  
  float scaleFactor = dist(lineStart.x,lineStart.y,lineEnd.x,lineEnd.y);
  float xDisplacement = lineEnd.x-lineStart.x;
  float yDisplacement = lineEnd.y-lineStart.y;
  
  addArc(-1,-1,lineEnd.x+xDisplacement/scaleFactor*distanceAway,lineEnd.y+yDisplacement/scaleFactor*distanceAway,angle);
}


void initPath() {  
 initPoints();
 
 for (int i = 0; i < pathSegments.size(); i++) {
    ArrayList<PVector> pathSegment = pathSegments.get(i); 
    PVector point1 = pathSegment.get(0);
    PVector point2 = pathSegment.get(1);
    
    if (pathSegment.size() == 4){
      pathLength += abs(pathSegment.get(arcValues).y * pathSegment.get(arcValues).z);
    }else{
      pathLength += dist(point1.x, point1.y, point2.x, point2.y);
    }
 }
}

void drawPath() {
  noFill();
  stroke(#4C6710);
  strokeWeight(PATH_RADIUS * 2 + 1);
  ellipseMode(CENTER);
  for (int i = 0; i < pathSegments.size(); i++) {
    ArrayList<PVector> pathSegment = pathSegments.get(i);
    PVector point2 = pathSegment.get(end);
    if (pathSegment.size() == 2){
      PVector point1 = pathSegment.get(start);
      
      stroke(#4C6710);
      strokeWeight(PATH_RADIUS * 2 + 1);
      line(point1.x, point1.y, point2.x, point2.y);
      
      stroke(#add558);
      strokeWeight(PATH_RADIUS * 3.2 + 1);
      line(point1.x, point1.y, point2.x, point2.y);
    }else{
      PVector arcData = pathSegment.get(arcValues);
      float angle1;
      float angle2;
      if (arcData.y <= 0){
        angle1 = arcData.x+arcData.y;
        angle2 = arcData.x;
      }else{
        angle2 = arcData.x+arcData.y;
        angle1 = arcData.x;
      }
       stroke(#4C6710);
       strokeWeight(PATH_RADIUS * 2 + 1);
       arc(point2.x,point2.y,arcData.z*2,arcData.z*2,angle1,angle2);
       
       stroke(#add558);
       strokeWeight(PATH_RADIUS * 3.2 + 1);
       arc(point2.x,point2.y,arcData.z*2,arcData.z*2,angle1,angle2);
    }
  }

  stroke(#7b9d32);
  strokeWeight(PATH_RADIUS * 2);
  for (int i = 0; i < pathSegments.size(); i++) {
    ArrayList<PVector> pathSegment = pathSegments.get(i);
    PVector point2 = pathSegment.get(end);
    if (pathSegment.size() == 2){
      PVector point1 = pathSegment.get(start);
      line(point1.x, point1.y, point2.x, point2.y);
    }else{
      PVector arcData = pathSegment.get(arcValues);
      float angle1;
      float angle2;
      if (arcData.y <= 0){
        angle1 = arcData.x+arcData.y;
        angle2 = arcData.x;
      }else{
        angle2 = arcData.x+arcData.y;
        angle1 = arcData.x;
      }
       arc(point2.x,point2.y,arcData.z*2,arcData.z*2,angle1,angle2);
    }
  }
}

HashMap<Float, PVector> dp = new HashMap<Float, PVector>();
// GIVEN TO PARTICIPANTS BY DEFAULT
PVector getLocation(float travelDistance)
{
  PVector memoized = dp.get(travelDistance);
  if(memoized != null) {
    return memoized;
  }
  float originalDist = travelDistance;
  
  float distance;
  PVector point1;
  PVector point2;
  
  for (int i = 0; i < pathSegments.size(); i++) {
    ArrayList<PVector> pathSegment = pathSegments.get(i);
    point1 = pathSegment.get(0);
    point2 = pathSegment.get(1);
    distance = dist(point1.x, point1.y, point2.x, point2.y);
    
    if (pathSegment.size() == 4){
      distance = abs(pathSegment.get(arcValues).y * pathSegment.get(arcValues).z);
    }
    if (distance <= EPSILON || travelDistance >= distance) {
      travelDistance -= distance;
    } else {
      // In between two pathSegments
      float x;
      float y;
      
      if (pathSegment.size() == 2){
        float xDist = point2.x - point1.x;
        float yDist = point2.y - point1.y;
         float travelProgress = travelDistance / distance;
        x = point1.x + xDist * travelProgress;
        y = point1.y + yDist * travelProgress;
      }
      else{
        PVector arcData = pathSegment.get(arcValues);
                   //initial angle  //radius
        float angle = arcData.x + ((1/arcData.z) * travelDistance * arcData.y/abs(arcData.y));
                          
        x = point2.x + arcData.z*cos(angle);
        y = point2.y + arcData.z*sin(angle);
      }
      dp.put(originalDist, new PVector(x, y));
      return new PVector(x, y);
    }
  }
  // At end of path
  ArrayList<PVector> lastPathSegment = pathSegments.get(pathSegments.size()-1);
  if (lastPathSegment.size() == 2){
    dp.put(originalDist, lastPathSegment.get(end));
    return lastPathSegment.get(end);
  }else{
    dp.put(originalDist, lastPathSegment.get(endArc));
    return lastPathSegment.get(endArc);
  }
}
