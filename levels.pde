class Level {
  int level; 
  color backgroundColor;
  float minEnemyRadius;
  float maxEnemyRadius;
  float minEnemySpeed;
  float maxEnemySpeed;
  int enemyHealth;
  Level(int level_, float minEnemyRadius_, float maxEnemyRadius_, float minEnemySpeed_, float maxEnemySpeed_) {
    level = level_;
    minEnemyRadius = minEnemyRadius_;
    maxEnemyRadius = maxEnemyRadius_;
    minEnemySpeed = minEnemySpeed_;
    maxEnemySpeed = maxEnemySpeed_;
    enemyHealth = 5;
  }
  Dot reset() {
    float newsines_and_gains[][] = new float[enemies2.size()][2];
    for (int i=0; i<enemies2.size(); i++) {
      newsines_and_gains[i][0]=100;
      newsines_and_gains[i][1]=0.1;
    }
    //obank.setFrequenciesAndGains(newsines_and_gains);
    //sps[themeFile].pause(true);
    //sps[themeFile].start();
    
    // loc_, vel_, lives_, dotColor_, alive_
    Dot dot = new Dot(new PVector(width/2, height/2), new PVector(0, 0), initNumLives, dotColor, false);
    numenemies = 1;
    deadenemies = 0;
    enemyHealth = 5;
    maxEnemySpeed = 1;
    maxEnemyRadius = 5;
    numbullets = 0;
    bullets = new ArrayList<Bullet>();
    enemies2 = new ArrayList<Enemy>();
    background(255, 255, 255);
    textFont(f, 50);
    fill(0, 0, 0);
    stroke(color(0, 0, 0));
    strokeWeight(3);
    text("YOU DIED AT LEVEL "+level, 50, height/2);
    text("Press P to start again", width/2-200, height/2+50);
    delay(3000);
    paused = !paused;
    if (paused) noLoop();
    level = 0;

    return dot;
  }
  Dot checkfornextlevel() {
    if (dot.lives==0) {
      return reset();
    }
    if (enemies2.size()==0) {//move on to the next level! spawn new enemies! make them faster!
      //trigger 'sound_tab_retreat_level_up
      playSound(levelUpFile, .2);
      resetPowerUps();
      numenemies+=1;
      level++;
      enemyHealth++;
      maxEnemySpeed += .05;
      maxEnemyRadius += .2;
      dot.traceLoc.clear();
      bullets = new ArrayList<Bullet>();
      float enemyEnemyDist;
      for (int i=0; i<numenemies; i++) {
        float newX = random(width);
        float newY = random(height);
        float newVx = random(-1, 1);
        float newVy = random(-1, 1);
        float xToDot = dot.loc.x-newX;
        float yToDot = dot.loc.y-newY;
        float angle = atan2(newVy-xToDot, newVx-yToDot);
        while ((abs(angle)+PI)%(2*PI)<PI/2) {
          newVx = random(-1, 1);
          newVy = random(-1, 1);
          xToDot = dot.loc.x-newX;
          yToDot = dot.loc.y-newY;
          angle = atan2(newVy-yToDot, newVx-xToDot);
        }

        for (int j=0; j<enemies2.size(); j++) {
          enemyEnemyDist = sqrt(pow(newX-enemies2.get(j).loc.x, 2)+pow(newY-enemies2.get(j).loc.x, 2));
          while ((abs(newX-dot.loc.x)<100 || abs(newY-dot.loc.y)<100 || enemyEnemyDist<2*maxEnemyRadius)) {
            newX = random(width);
            newY = random(height);
            enemyEnemyDist = sqrt(pow(newX-enemies2.get(j).loc.x, 2)+pow(newY-enemies2.get(j).loc.x, 2));
          }
        }
        enemies2.add(new Enemy(new PVector(newX, newY), new PVector(maxEnemySpeed*newVx, maxEnemySpeed*newVy), color(255, 255, 255), maxEnemyRadius, enemyHealth));
      }
    }
    return dot;
  }
}
