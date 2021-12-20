// -------------- TEMPLATE CODE BEGINS ---------------- (Participants will NOT need to code anything below this line)

ArrayList<PVector> center = new ArrayList<PVector>(), velocity = new ArrayList<PVector>(); // Stores the location of each projectile and how fast it should move each frame
ArrayList<float[]> projectileData = new ArrayList<float[]>(); // Stores additional projectile data (unrelated to motion)
ArrayList<HashSet<Integer>> balloonsHit = new ArrayList<HashSet<Integer>>(); // Stores a list of balloons that each projectile has hit, so it doesn't hit the same balloon twice 
// For Participants: The HashSet data structure is like an ArrayList, but can tell you whether it contains a value or not very quickly
// The downside of HashSets is that there is no order or indexes, so you can't use it like a normal list
// Think of it like throwing items into an unorganized bin 

final int damage = 0, pierce = 1, angle = 2, currDistTravelled = 3, maxDistTravelled = 4, thickness = 5, dmgType = 6; // Constants to make accessing the projectileData array more convenient
final int projectileRadius = 11;

//changed values to help upgrades
int defdmg = 6, eightdmg = 4, slowdmg = 1;
int shots = 8;
float slowPercent = 0.7;

// Adds a new projectile
void createProjectile(PVector centre, PVector vel, float damage, int pierce, float maxDistTravelled, float thickness, int dmgType) {
  balloonsHit.add(new HashSet<Integer>()); // Adds an empty set to the balloonsHit structure - this represents the current projectile, not having hit any balloons yet.
  center.add(centre); // Adds the starting location of the projectile as the current location
  velocity.add(vel); // Adds the velocity of the projectile to the list
  float angle = atan2(vel.y, vel.x);
  projectileData.add(new float[]{damage, pierce, angle, 0, maxDistTravelled, thickness, dmgType});
}

// Checks the distance from a point to a projectile using the pointDistToLine() method coded earlier
float distToProjectile(int projectileID, PVector point) {
  float[] data = projectileData.get(projectileID);
  float width = cos(data[angle]), height = sin(data[angle]);
  PVector displacement = new PVector(width, height).mult(projectileRadius);
  PVector start = PVector.add(center.get(projectileID), displacement), end = PVector.sub(center.get(projectileID), displacement);
  return pointDistToLine(start, end, point);
}

// Checks if a projectile is ready to be removed (is it off screen? has it already reached its maximum pierce? has it exceeded the maximum distance it needs to travel?)
public boolean dead(int projectileID) {
  float[] data = projectileData.get(projectileID);
  return offScreen(projectileID) || data[pierce] == 0 || data[currDistTravelled] > data[maxDistTravelled];
}

// Checks if a projectile is off-screen 
public boolean offScreen(int projectileID) {
  return center.get(projectileID).x < 0 || center.get(projectileID).x > 800 || center.get(projectileID).y < 0 || center.get(projectileID).y > 500;
}

// Displays a projectile and handles movement & collision via their respective methods
void drawProjectile(int projectileID) {
  float[] data = projectileData.get(projectileID);
  stroke(255);
  strokeWeight(data[thickness]);
  float width = cos(data[angle]), height = sin(data[angle]);
  PVector displacement = new PVector(width, height).mult(projectileRadius);
  PVector start = PVector.add(center.get(projectileID), displacement), end = PVector.sub(center.get(projectileID), displacement);
  line(start.x, start.y, end.x, end.y);

  handleProjectileMovement(projectileID);
  handleCollision(projectileID);
}

// Updates projectile locations
void handleProjectileMovement(int projectileID) {
  PVector nextLocation = PVector.add(center.get(projectileID), velocity.get(projectileID)); // Adds the velocity to the current position
  center.set(projectileID, nextLocation); // Updates the current position
  
  float[] data = projectileData.get(projectileID);
  data[currDistTravelled] += velocity.get(projectileID).mag(); // Tracks the current distance travelled, so that if it exceeds the maximum projectile range, it disappears
}

// Checks collision with balloons
void handleCollision(int projectileID) {
  float[] data = projectileData.get(projectileID);
  for (float[] balloon : balloons) {
    if (balloon[delay] > 0) continue; // If the balloon hasn't entered yet, don't count it
    PVector position = getLocation(balloon[distanceTravelled]);
    if (distToProjectile(projectileID, position) <= balloonRadius / 2 + data[thickness] / 2) {
      if (data[pierce] == 0 || balloonsHit.get(projectileID).contains((int) balloon[ID])) continue; // Already hit the balloon / already used up its max pierce
      data[pierce]--; // Lowers the pierce by 1 after hitting the balloon
      balloonsHit.get(projectileID).add((int) balloon[ID]); // Adds the projectile to the set of already hit balloons
      hitBalloon(projectileID, balloon);
    }
  }
}
// -------------- TEMPLATE CODE ENDS ---------------- (Participants will NOT need to code anything above this line)

// Code that is called when a projectile hits a balloon
void hitBalloon(int projectileID, float[] balloonData) {
  float[] data = projectileData.get(projectileID);

  balloonData[hp] -= data[damage]; // Deals damage
  
  if (data[dmgType] == slow && balloonData[slowed] == 0) { // Slows down the balloon
    float slowNum = slowPercent;
    if (data[upgrade] >= 2) {
      slowNum -= 0.2;
    }
    balloonData[speed] *= slowNum;
    balloonData[slowed] = 1;
  }
}

// Tracks the tower that is closest to the end, within the vision of the tower
PVector track(PVector towerLocation, int vision) {
  float maxDist = 0;
  PVector location = null;
  for (float[] balloon : levels.get(levelNum)) {
    PVector balloonLocation = getLocation(balloon[distanceTravelled]);
    // Checks if the tower can see the balloon
    if (dist(balloonLocation.x, balloonLocation.y, towerLocation.x, towerLocation.y) <= vision) {
      // If the balloon has travelled further than the previously stored one, it is now the new fastest
      if (balloon[distanceTravelled] > maxDist) {
        location = balloonLocation;
        maxDist = balloon[distanceTravelled];
      }
    }
  }
  return location;
}

// Handles all projectile creation
void handleProjectiles() {
  if (playingLevel) {
    for (int i = 0; i < towers.size(); i++) {
      PVector location = towers.get(i);
      int[] data = towerData.get(i);
      data[cooldownRemaining]--;
      PVector balloon = track(location, data[towerVision]);
  
      // Cooldown is 0 and there is a balloon that the tower tracks shoots a projectile
      if (data[cooldownRemaining] <= 0 && balloon != null) {
        data[cooldownRemaining] = (int)(data[maxCooldown] * speedBoostAmount); // Resets the cooldown
  
        PVector toMouse = new PVector(balloon.x - location.x, balloon.y - location.y);
  
        if (data[projectileType] == def) {
          int speed = 24, damage = defdmg, pierce = 1, thickness = 2, maxTravelDist = 500;
          if (data[upgrade] >= 3) {
            damage = defdmg + data[upgrade] - 2;
          }
          PVector unitVector = PVector.div(toMouse, toMouse.mag());
  
          PVector velocity = PVector.mult(unitVector, speed);
          createProjectile(location, velocity, damage, pierce, maxTravelDist, thickness, def);
          // Default type
        } else if (data[projectileType] == eight) {
          // Spread in 8
          int curShots = shots;
          if (data[upgrade] >= 3) {
            curShots = shots + 8;
          }
          
          for (int j = 0; j < curShots; j++) {
            int speed = 18, damage = eightdmg, pierce = 2, thickness = 2, maxTravelDist = 150;
            float angle = (PI * 2) * j / curShots;
            PVector unitVector = PVector.div(toMouse, toMouse.mag());
            if (data[upgrade] >= 4) {
              damage = eightdmg + data[upgrade] - 3;
            }
            PVector velocity = PVector.mult(unitVector, speed).rotate(angle);
            createProjectile(location, velocity, damage, pierce, maxTravelDist, thickness, eight);
          }
        } else if (data[projectileType] == slow) {
          //glue gunner - slows balloons
          final int speed = 15, damage = slowdmg, pierce = 7, thickness = 4, maxTravelDist = 220; //slow-ish speed, low damage, high pierce, low range
          PVector unitVector = PVector.div(toMouse, toMouse.mag());
  
          PVector velocity = PVector.mult(unitVector, speed);
          createProjectile(location, velocity, damage, pierce, maxTravelDist, thickness, slow);
        }
      }
    }
  }
  // Displays projectiles and removes those which need to be removed
  for (int projectileID = 0; projectileID < projectileData.size(); projectileID++) {
    drawProjectile(projectileID);
    if (dead(projectileID)) {
      projectileData.remove(projectileID);
      center.remove(projectileID);
      velocity.remove(projectileID);
      balloonsHit.remove(projectileID);
      projectileID--;
    }
  }
}
