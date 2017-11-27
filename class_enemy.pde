class Enemy {
  float x, y, z, r;
  float vx, vy, vz;
  Enemy(float x_, float y_, float z_, float vx_, float vy_, float vz_) {
    r=20;
    x=x_;
    y=y_;
    z=z_;
    vx=vx_;
    vy=vy_;
    vz=vz_;
  }
  void updateEnemy() {
    x=x+vx;
    y=y+vy;
    if (x>=width) {
      vx*=-1;
      //x=0;
    }
    if (x<=0) {
      vx*=-1;
      //x=width;
    }
    if (y>=height) {
      //y=0;
      vy*=-1;
    }
    if (y<=0) {
      //y=height;
      vy*=-1;
    }
  }
  void hitanotherEnemy(Enemy hitenemy) {

    float oldhitenemyvx=hitenemy.vx;
    float oldhitenemyvy=hitenemy.vy;
    float currentenemyvx=this.vx;
    float currentenemyvy=this.vy;
    hitenemy.vx=currentenemyvx;
    hitenemy.vy=currentenemyvy;
    this.vx=oldhitenemyvx;
    this.vy=oldhitenemyvy;
  }
  void updateEnemy(float vx_, float vy_, float vz_) {
    x+=vx_;
    y+=vy_;
    //z+=vz_;
    //periodic boundary conditions
    if (x>=width) {
      vx*=-1;
      //x=0;
    }
    if (x<=0) {
      vx*=-1;
      //x=width;
    }
    if (y>=height) {
      //y=0;
      vy*=-1;
    }
    if (y<=0) {
      //y=height;
      vy*=-1;
    }
    //if (z>width) {
    //  z=0;
    //  vz*=-1;
    //}
    //if (z<0) {
    //  z=width;
    //  vz*=-1;
    //}
  }
  void drawEnemy() {
    pushMatrix();
    translate(x, y);
    fill(0, 0, 255);
    ellipse(0, 0, r, r);
    popMatrix();
  }
}
void updateenemies() {
  Bullet currentbullet;
  Enemy updateenemy, updateenemy2;
  for (int i=0; i<enemies2.size(); i++) {
    updateenemy=enemies2.get(i);
    //check for death of dot
    if (((dot.x-updateenemy.x)*(dot.x-updateenemy.x)+(dot.y-updateenemy.y)*(dot.y-updateenemy.y))<=((updateenemy.r+dot.r)*(updateenemy.r+dot.r))) {
      deathcount++;
      enemies2.remove(i);
      //numenemies--;
    }
    //check if enemies have hit eachother, make bounce off
    for (int k=0; k<enemies2.size(); k++) {
      updateenemy2=enemies2.get(k);
      if ((updateenemy.x-updateenemy2.x)*(updateenemy.x-updateenemy2.x)+(updateenemy.y-updateenemy2.y)*(updateenemy.y-updateenemy2.y)<(updateenemy.r+updateenemy2.r)*(updateenemy.r+updateenemy2.r)) {
        updateenemy.hitanotherEnemy(updateenemy2);
      }
    }
    for (int j=0; j<bullets.size(); j++) {
      currentbullet=bullets.get(j);
      //removes bullet if too old
      if (currentbullet.lifetime>10) {
        bullets.remove(j);
      }
      //if bullet hits an enemy
      if (((currentbullet.x-updateenemy.x)*(currentbullet.x-updateenemy.x)+(currentbullet.y-updateenemy.y)*(currentbullet.y-updateenemy.y))<=((updateenemy.r)*(updateenemy.r))) {
        deadenemies+=1;
        //numenemies--;
        sp1.setToLoopStart();
        sp2.start();
        //remove the enemy
        enemies2.remove(updateenemy);
        
        //remove the bullet
        bullets.remove(j);
        numbullets--;
        //create new variables for a replacement enemy
        float newx=random(width);
        float newy=random(height);
        //check if new enemy is added near the dot
        while ((newx-dot.x)*(newx-dot.x)+(newy-dot.y)*(newy-dot.y)<dot.r*dot.r) {
          newy=random(height);
          newx=random(width);
        }
        //adding a second enemy after enemies dies to increase difficulty increases latency of the program
        //enemies2.add(new Enemy(newx, newy, -random(height), random(-1, 1), random(-1, 1), random(-1, 1)));
        //while ((newx-dot.x)*(newx-dot.x)+(newy-dot.y)*(newy-dot.y)<dot.r*dot.r) {
        //  newy=random(height);
        //  newx=random(width);
        //}
        //enemies2.add(new Enemy(newx, newy, -random(height), random(-1, 1), random(-1, 1), random(-1, 1)));
      }
    }
    //enemies[i].updateEnemy();
    updateenemy.updateEnemy();
    //enemies[i].drawEnemy();
    updateenemy.drawEnemy();
    //check for bullet hitting enemy
    dot.updateDot(-map(xAxis, -180, 180, -10, 10), map(yAxis, -180, 180, -10, 10), map(zAxis, -180, 180, -10, 10));
    dot.drawDot();
  }
}
void checkfornextlevel() {
  if (enemies2.size()==0) {
    numenemies+=1;
    level++;
    for (int i=0; i<numenemies; i++) {
      enemies2.add(new Enemy(random(width), random(height), -random(height), random(-1, 1), random(-1, 1), random(-1, 1)));
    }
  }
}