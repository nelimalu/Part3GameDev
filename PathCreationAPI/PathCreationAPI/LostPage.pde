int framesSinceLost = 0;
void drawLostAnimation() {
  framesSinceLost++;
 
  float alpha = 166 * framesSinceLost / 80;
  if (alpha > 166) alpha = 166;
  fill(127, 50, 50, alpha);
  rectMode(CORNER);
  noStroke();
  rect(0, 0, WIDTH, HEIGHT);
  
  float textAlpha = 255 * (framesSinceLost - 80) / 80;
  if (textAlpha > 255); textAlpha = 255;
  fill(255, textAlpha);
  textSize(70);
  text("GAME OVER", WIDTH / 2 - (textWidth("GAME OVER") / 2), HEIGHT / 2 - 10);
  
  /*
  textSize(40);
  text("Click Anywhere to Play Again", WIDTH / 2 - (textWidth("Click Anywhere to Play Again") / 2), HEIGHT / 2 + 30);
  // text("GAME OVER", 265, 260);
  
  if (mousedown) {
    balloons = new ArrayList<float[]>();
    levels = new ArrayList<ArrayList<float[]>>();
    speedUp = false;
    playingLevel = false;
    currentBalance = 750;
    health = 11;
    initPath();
    createWaves();
    createGrass();
  }
  */
}
