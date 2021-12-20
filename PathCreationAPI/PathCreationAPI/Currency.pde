/** Currency system for tower defense
 *  - Rewards player for popping balloon
 *  - Keeps track of balance
 *  - Checks for sufficient funds when purchasing tower
 */

// Current amount of money owned by the player
int currentBalance = 750; // Give the user $750 of starting balance
final int rewardPerBalloon = 15; // Money earned by popping a balloon
final int baseRewardPerWave = 10; //base money earned per wave

void handleBalloonPop() {
  // Reward the player for popping the balloon
  increaseBalance(rewardPerBalloon);
}


void increaseBalance(int amount) {
  currentBalance += amount; // Increase the current balance by the amount given
}

//method to give user money for completing a wave
void handleWaveReward(int waveNum) {
   increaseBalance(baseRewardPerWave * waveNum);
}

/** Checks to see if there is sufficient balance for purchasing a certain item
 *  Parameter "cost" is the cost of the tower to be purchased
 */
boolean hasSufficientFunds(int cost) {
  if (currentBalance < cost) {
    return false; // Not enough money to purchase the tower
  }
  else {
    return true; // Enough money to purchase the tower
  }
}

/** Purchases a tower
 *  Parameter "cost" is the cost of the tower to be purchased
 */
void purchaseTower(int cost) {
  currentBalance -= cost;
}

// Checks to see if the user is attempting to purchase/pick up a tower but has insufficient funds
boolean attemptingToPurchaseTowerWithoutFunds(int towerID) {
  if (mousePressed && withinBounds(towerID) && !hasSufficientFunds(towerPrice[towerID])) {
    return true;
  }
  else {
    return false;
  }
}

// Displays the user's current balance on the screen
void drawBalanceDisplay() {
  // If the user is attempting to purchase a tower without funds, warn them with red display text
  boolean error = false;
  for (int i = 0; i < towerCount; i++) {
    if (attemptingToPurchaseTowerWithoutFunds(i)) {
      error = true;
    }
  }
  if (error) {
    fill(towerErrorColour);
  }
  else {
    fill(0); // Black text
  }
  
  text("Current Balance: $" + currentBalance, 336, 20);
}
