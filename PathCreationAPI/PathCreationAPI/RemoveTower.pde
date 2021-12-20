PVector removeLocation = new PVector(255, 470);
void drawRemove() {
  strokeWeight(1);
  stroke(#deac9e);
  fill(#FF6961);
  rectMode(CENTER);
  rect(removeLocation.x, removeLocation.y, 70, 24,5); 
  textSize(16);
  fill(#ffffff);
  text("Remove", removeLocation.x - 30, removeLocation.y+4);
}
void removeCheck() {
  if((removeLocation.x - 35 <= mouseX && mouseX <= removeLocation.x + 35 && removeLocation.y - 12 <= mouseY && mouseY <= removeLocation.y + 12) && mousePressed && towerClicked != -1) {
    int[] temp = towerData.get(towerClicked);
    currentBalance += temp[upgrade] * towerPrice[temp[projectileType]] / 2;
    int temp1 = towerClicked; towerClicked = -1;
    towerData.remove(temp1); towers.remove(temp1);
  }
}
