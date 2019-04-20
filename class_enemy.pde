class Enemy {
  PVector loc, vel;
  ArrayList<PVector> traceLoc;
  float r;
  color enemyColor;
  int health;
  int hitWallSoundFile;
  int deadSoundFile;
  int entrappedSoundFile;
  int tracelen;
  boolean hitwall;
  boolean updated;
  Enemy(PVector loc_, PVector vel_, color enemyColor_, float radius_, int health_) {
    loc = loc_;
    r = 20;
    vel = vel_;
    enemyColor = enemyColor_;
    r = radius_;
    health = health_;
    updated = true;
    hitwall = false;
    for (int f=0; f<files.length; f++) {
      if (files[f].getName().equals("sound_click_sharp.wav")) {
        hitWallSoundFile = f;
      }
      if (files[f].getName().equals("sound_decoupler_fire.wav")) {
        deadSoundFile = f;
      }
      if (files[f].getName().equals("particle_entrapped.wav")) {
        entrappedSoundFile = f;
      }
    }
    //tracelen = int(15/vel.mag());
    //traceLoc = new ArrayList<PVector>();
  }
  void updatePBC() {
    if (loc.x>=width) {
      vel.x*=-1;
      loc.x = width - (loc.x-width);
      loc = loc.add(vel);
      hitwall = true;
      playSound(hitWallSoundFile, .05);
    } else if (loc.x<=0) {
      vel.x*=-1;
      loc.x*=-1;
      loc = loc.add(vel);
      hitwall = true;
      playSound(hitWallSoundFile, .05);
    } else if (loc.y>=height) {
      vel.y*=-1;
      loc.y = width - (loc.y-width);
      loc = loc.add(vel);
      hitwall = true;
      playSound(hitWallSoundFile, .01);
    } else if (loc.y<=0) {
      vel.y*=-1;
      loc.y*=-1;
      loc = loc.add(vel);
      hitwall = true;
      playSound(hitWallSoundFile, .05);
    } else {
      loc = loc.add(vel);
    }
  }
  void updateEnemy() {
    float oldmag = vel.mag();
    if (!invincible || (invincible && hitwall)) {
      vel = vel.add(dot.loc.copy().sub(loc).mult(0.1)).setMag(oldmag);
    } else {
      vel = vel.add(dot.loc.copy().sub(loc).mult(-0.1)).setMag(oldmag);
    }
    updatePBC();
    //while ( loc.x <0 || loc.y < 0 || loc.x > width || loc.y > height) {
    //  //loc.set(random(width), random(height));
    //  loc = loc.add(vel);
    //}
    //traceLoc.add(loc.copy());
    //if (traceLoc.size() > this.tracelen) {
    //  traceLoc.remove(0);
    //}
    //r+=1;
  }
  //if we hit another enemy use the conservation of momentum 
  void hitanotherEnemy(Enemy hitenemy) {
    float oldhitenemyvx = hitenemy.vel.x;
    float oldhitenemyvy = hitenemy.vel.y;
    float currentenemyvx = this.vel.x;
    float currentenemyvy = this.vel.y;
    hitenemy.vel.x = currentenemyvx;
    hitenemy.vel.y = currentenemyvy;
    this.vel.x = oldhitenemyvx;
    this.vel.y = oldhitenemyvy;
    hitenemy.updateEnemy();
    updateEnemy();
    playSound(hitWallSoundFile, .1);
  }

  void updateEnemy(PVector vel_) {
    updated = true;
    if (loc.x>width) {
      vel.x*=-1;
    }
    if (loc.x<0) {
      vel.x*=-1;
    }
    if (loc.y>height) {
      vel.y*=-1;
    }
    if (loc.y<0) {
      vel.y*=-1;
    }
    loc.x+=vel_.x;
    loc.y+=vel_.y;
  }
  void drawEnemy() {
    pushMatrix();
    translate(loc.x, loc.y);

    //PShape trace = createShape();

    //trace.beginShape();
    //for (float ang = 0; ang < 2*PI; ang+=.1) {
    //  float xoff = cos(ang) + 1;
    //  float yoff = sin(ang) + 1;
    //  float rnew = map(noise(xoff, yoff), 0, 1, 10, 50);
    //  println(rnew);
    //  float newx = rnew*cos(ang);
    //  float newy = rnew*sin(ang);
    //  trace.vertex(newx, newy);
    //}
    //trace.setFill(color(255, 0, 0));
    //trace.setStroke(color(255, 0, 0));
    //trace.endShape(CLOSE);
    //shape(trace,0,0);
    float mag = sqrt(pow(vel.x, 2)+pow(vel.y, 2));
    float a = (acos(vel.x/mag)+PI);//%(2*PI);
    if (vel.y<0 && vel.x<0) {
     a = -a+PI;
    } else if (vel.y<0 && vel.x>0) {
     a = -a+PI;
    }
    rotate(a);
    color f = blendColor(enemyColor, mapcolor, DIFFERENCE);
    color s = lerpColor(enemyColor, f, map(health-level.enemyHealth, 0, level.enemyHealth, 1, 0));
    stroke(s);
    fill(s);
    ellipse(0, 0, r+mag, r-mag);
    popMatrix();
    //pushMatrix();
    //PShape trace = createShape();   
    //trace.beginShape();
    //for (int i = 0; i < traceLoc.size(); i++) {
    //  PVector currloc = traceLoc.get(i).copy();
    //  trace.vertex(currloc.x, currloc.y);
    //}
    //trace.endShape();
    ////trace.setFill(mapcolor);
    //trace.setStroke(s);
    //shape(trace, 0, 0);
    //popMatrix();
  }
}
void updateenemies() {
  Bullet currentbullet;
  float newsines_and_gains[][] = new float[enemies2.size()][2]; 
  //float newgains[] = new float[enemies2.size()];
  for (int p=0; p<powerUps.size(); p++) {
    if (powerUps.get(p).type.equals("invincibility") && powerUps.get(p).activated) {
      invincible = true;
    }
  }
  float newgain = .025/numenemies;
  Enemy updateenemy, updateenemy2;
  for (int i=0; i < enemies2.size(); i++) {
    updateenemy = enemies2.get(i);
    PVector updateenemyloc = updateenemy.loc;
    if (dot.p.contains(int(updateenemyloc.x), int(updateenemyloc.y))) {
      //println("inside");
      updateenemy.health-=1;
      if (updateenemy.health<=0) {
        //remove the enemy
        deadenemies+=1;
        enemies2.remove(updateenemy);
        playSound(updateenemy.entrappedSoundFile, .06);
        dot.tracelen++;
      }
    }
    updateenemy.updated = false;
    //check for death of dot
    float dot_to_enemy = dot.loc.dist(updateenemyloc);
    newsines_and_gains[i][0] = (width*sqrt(3)-dot_to_enemy)/2;
    newsines_and_gains[i][1] = newgain;
    if (invincible) {
      if (dot_to_enemy <= (updateenemy.r+dot.r)/2) {
        updateenemy.vel.mult(-1);
        //updateenemy.vel.add(dot.vel);
      }
    } else if (dot_to_enemy <= (updateenemy.r+dot.r)/2) {
      dot.lives--;
      serial.write('1');
      enemies2.remove(i);
      //sps[lostLifeFile].pause(false);
      playSound(lostLifeFile, .05);
    }
    //check if enemies have hit eachother, make bounce off
    //if we don't have any enemies, we don't need to do this
    if (!(enemies2.size()<=1)) {
      for (int k=0; k<enemies2.size(); k++) {
        if (k!=i) {
          updateenemy2 = enemies2.get(k);
          if (updateenemyloc.dist(updateenemy2.loc) < (updateenemy.r/2+updateenemy2.r/2)) {
            updateenemy.hitanotherEnemy(updateenemy2);
          }
        }
      }
    }
    for (int j=0; j<bullets.size(); j++) {
      currentbullet = bullets.get(j);
      float dist = currentbullet.loc.dist(updateenemyloc);
      if (dist <= updateenemy.r) {//&& red(u)==red(d) && blue(u)==blue(d) && green(u)==green(d)) {
        updateenemy.health-=1;
        for (int f=0; f<files.length; f++) {
          if (files[f].getName().equals("synth"+updateenemy.health+".wav")) {
            gainValues[f].setValue(.2);
            sps[f].setLoopStart(sps[f]);
            sps[f].setToLoopStart();
            sps[f].start();
          }
        }
        //if the enemy is out of health
        if (updateenemy.health<=0) {
          //remove the enemy
          deadenemies+=1;
          currExplosions.add(new Explosion(new PVector(updateenemyloc.x, updateenemyloc.y), new PVector(updateenemy.vel.x, updateenemy.vel.y)));
          playSound(updateenemy.deadSoundFile, .06);
          enemies2.remove(updateenemy);
        }
        //remove the bullet
        bullets.remove(j);
        numbullets--;
      }
    }
    if (updateenemy.updated==false) {
      updateenemy.updateEnemy();
    }
    updateenemy.drawEnemy();
  }
  accel = new PVector(-map(xAxis, -180, 180, -10, 10), map(yAxis, -180, 180, -10, 10));
  dot.updateDot(accel);
  obank.setNumOscillators(numenemies);
  obank.setFrequenciesAndGains(newsines_and_gains);
  //sps[lostLifeFile].pause(true);
}
class Explosion {
  PVector loc, vel;
  int age;
  Explosion (PVector loc_, PVector vel_) {
    loc = loc_;
    vel = vel_;
    age = xplodefiles.length;
  }
}

void animateExplosions() {
  if (currExplosions.size()!=0) {
    int giflen = xplodefiles.length;
    for (int i = 0; i<currExplosions.size(); i++) {
      pushMatrix();
      Explosion currExp = currExplosions.get(i);
      translate(currExp.loc.x-25+(giflen-currExp.age)*currExp.vel.x, currExp.loc.y-25+(giflen-currExp.age)*currExp.vel.y);
      tint(255, 126);
      image(xplode[giflen-currExp.age], 0, 0, 50, 50);
      popMatrix();
      currExp.age-=1;
      if (currExp.age==0) {
        currExplosions.remove(i);
      }
    }
  }
}

void playSound(int f, float gain) {
  gainValues[f].setValue(gain);
  sps[f].setToLoopStart();
  sps[f].start();
}