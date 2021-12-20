//To upgrade towers, click them and their radius will show around them. Click the upgrade button to upgrade the tpower to the next level
PVector upgradeLocation = new PVector(145, 470);
void towerClickCheck() {
  if (mousePressed) {
    towerClicked = -1;
  }
  for (int i = 0; i < towers.size(); i++) {
    float xPos = towers.get(i).x, yPos = towers.get(i).y;
    if(pointRectCollision(mouseX, mouseY, xPos, yPos, towerSize) && mousePressed) {
      // Drawing the tower range visually 
      towerClicked = i;
    }
  }
}
void drawRange() {
  if (towerClicked != -1) {
    float xPos = towers.get(towerClicked).x, yPos = towers.get(towerClicked).y;
    int[] data = towerData.get(towerClicked);
    fill(127, 80);
    stroke(127);
    strokeWeight(4);
    ellipseMode(RADIUS);
    ellipse(xPos, yPos, data[towerVision], data[towerVision]);
  }
}

// method to get damage numbers from the type of tower's projectile
int dmgFromProjectileType(int type, int[] temp){
  if(type==0) {
    int ret = defdmg;
    if (temp[upgrade] >= 3) {
      ret += temp[upgrade] - 2;
    }
    return ret;
  }
  else if(type==1) {
    int ret = eightdmg;
    if (temp[upgrade] >= 4) {
      ret += temp[upgrade] - 3;
    }
    return ret;
  }
  else if(type==2) {
    return slowdmg;
  }
  return 0;
}

// draw the tower UI - includes the remove option
void drawTowerUI(){
  if(towerClicked != -1) {
    //draw outer box for upgrades
    int[] temp = towerData.get(towerClicked);
    stroke(#add558);
    strokeWeight(1);
    fill(#E7EAB5);
    rect(200,450,216,80,3);
    fill(#444941);
    text("Current Level: " + temp[upgrade],98,426);
    text("range: "+ temp[towerVision],104,446);
    text("damage: "+ (dmgFromProjectileType(temp[projectileType], temp)),204,446);
    strokeWeight(2);
    stroke(#a8a89d,200);
    line(100,453,295,453);
    
    drawUpgrade();
    upgradeCheck();
    drawRemove();
    removeCheck();
  }
}

//EDIT THIS FOR UI FOR UPGRADES
void drawUpgrade() {
  strokeWeight(0);
  stroke(0);
  fill(#C364FF);
  rectMode(CENTER);
  rect(upgradeLocation.x, upgradeLocation.y, 86, 24,5); 
  textSize(16);
  fill(255);
  int[] temp = towerData.get(towerClicked);
  text("Buy: $" + towerPrice[temp[projectileType]] / 2, upgradeLocation.x-40, upgradeLocation.y+4);
}
void upgradeCheck() {
  if((upgradeLocation.x - 43 <= mouseX && mouseX <= upgradeLocation.x + 43 && upgradeLocation.y - 12 <= mouseY && mouseY <= upgradeLocation.y + 12) && mousePressed && towerClicked != -1) {
    int[] temp = towerData.get(towerClicked);
    if (currentBalance >= towerPrice[temp[projectileType]] / 2) {
      temp[upgrade]++; currentBalance -= towerPrice[temp[projectileType]] / 2 ;
      if (temp[projectileType] == 0) {
        if (temp[upgrade] == 2) { //first upgrade
          temp[maxCooldown] = 8; //increases attack speed
        }
      } else if (temp[projectileType] == 1) {
        if (temp[upgrade] == 2) { //second upgrade
          temp[towerVision] += 50;
        }
      } else if (temp[projectileType] == 2) {
        if (temp[upgrade] > 2) {
          temp[towerVision] += 50;
        }
      }
      towerData.set(towerClicked, temp);
      println("tower number: " + (towerClicked + 1) + ", upgrade level: " + temp[upgrade]);
    }
  } 
}
