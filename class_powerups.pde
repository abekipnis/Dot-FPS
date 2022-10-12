
class PowerUp {
  // initializer for powerup object
  String type; // the type of powerup 
  int age; // how long will the powerup stay around until it disappears
  int activated_time; // how long will the powerup stay activated
  color powerUpColor; // color of the powerup
  PVector loc, vel; // location and velocity vectors of powerup
  boolean activated; 
  boolean visible;
  float start_time;
  int level_appearances[];
  int soundFile;
  PowerUp(String type_, int age_, int activated_time_, int level_appearances_[], PVector loc_, PVector vel_) {
    type = type_;
    age = age_;
    loc = loc_;
    vel = vel_;
    activated = false;
    visible = true;
    level_appearances = level_appearances_;
    activated_time = activated_time_;
    for (int f=0; f<files.length; f++) {
      if (files[f].getName().equals("invincible.wav") && type.equals("invincibility")) {
        soundFile = f;
      } else if (files[f].getName().equals("longer_bullet_lifetime.wav") && type.equals("longer_bullets")) {
        soundFile = f;
      } else if (files[f].getName().equals("double_trace.wav") && type.equals("double_trace")) {
        soundFile = f;
      }
    }
  }
  void drawPowerUp() {
    pushMatrix();
    translate(loc.x, loc.y);
    if (type.equals("invincibility")) {
      rect(-15, -15, 15, 15);
    } else if (type.equals("extra_life")) {
      image(extra_life, -25, -25, 50, 50);
    } else if (type.equals("longer_bullets")) {
      rect(-8, -8, 8, 8);
    } else if (type.equals("double_trace")) {
      stroke(255, 0, 0);
      text("x2 tracelen", 0, 0);
    }
    popMatrix();
  }
  void updatePowerUp() {
    if (loc.dist(dot.loc)<dot.r/2) {
      activated = true;
      visible = false;
      if (type.equals("extra_life")) {
        dot.lives++;
        playSound(extraLifeFile, .1);
      } else {
        gainValues[soundFile].setValue(0.1);
        sps[soundFile].setToLoopStart();
        sps[soundFile].setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
        sps[soundFile].start();
      }
      //start_time = millis();
    }
    if (activated == true) {
      if (type.equals("longer_bullets")) {
        bulletMaxLifetime*=2;
      }
      if (type.equals("double_trace")) {
        dot.oldtracelen = dot.tracelen;
        dot.tracelen*=2;
      }
    }
    if (visible == true) {
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
      loc.add(vel);
      drawPowerUp();
    }
  }
}

void initPowerUps() {
  int max_levels = 35;
  int longer_bullets_appearances[] = new int[max_levels];
  int invincibility_appearances[] = new int[max_levels];
  int extra_life_appearances[] = new int[max_levels];
  int double_trace_apps[] = new int[max_levels];

  for (int i=0; i<max_levels; i++) {
    longer_bullets_appearances[i] = -1;
    invincibility_appearances[i] = -1;
    extra_life_appearances[i] = -1;
    double_trace_apps[i] = -1;
    if (i>=5) {
     longer_bullets_appearances[i] = i;
     extra_life_appearances[i] = i;
     //double_trace_apps[i] = i;
    }
    if (i>=1) {
     double_trace_apps[i] = i;
     invincibility_appearances[i] = i;
    }
  }
  powerUps.add(new PowerUp("longer_bullets", 1000, 1000, longer_bullets_appearances, new PVector(random(width), random(height)), new PVector(random(-.5, .5), random(-.5, .5))));
  powerUps.add(new PowerUp("invincibility", 1000, 1000, invincibility_appearances, new PVector(random(width), random(height)), new PVector(random(-.5, .5), random(-.5, .5))));
  powerUps.add(new PowerUp("extra_life", 1000, 1000, extra_life_appearances, new PVector(random(width), random(height)), new PVector(random(-.5, .5), random(-.5, .5))));
  powerUps.add(new PowerUp("double_trace", 1000, 1000, double_trace_apps, new PVector(random(width), random(height)), new PVector(random(-.5, .5), random(-.5, .5))));
}
void animatePowerUps() {
  //go through all possible powerups
  for (int i=0; i<powerUps.size(); i++) {
    PowerUp thisPowerUp = powerUps.get(i);
    //println(thisPowerUp.type, thisPowerUp.age, thisPowerUp.activated_time, thisPowerUp.visible, thisPowerUp.activated);
    //if we're on a level that requires a powerup to pass...
    for (int j=0; j<thisPowerUp.level_appearances.length; j++) {
      if (level.level == thisPowerUp.level_appearances[j]) {
        if (thisPowerUp.age == 0 && thisPowerUp.visible) {
          thisPowerUp.visible = false;
        } else if (thisPowerUp.visible) {
          thisPowerUp.updatePowerUp();
        } else if (thisPowerUp.activated && thisPowerUp.activated_time>0) {
          //println(thisPowerUp.type,millis()-thisPowerUp.start_time);
          thisPowerUp.activated_time--;
        }
        if (thisPowerUp.activated_time==0) {//undo the power-up power if its expired
          if (thisPowerUp.type.equals("longer_bullets")) {
            bulletMaxLifetime = initBulletMaxLifetime;
          }
          if (thisPowerUp.type.equals("double_tracelen")) {
            dot.tracelen = dot.oldtracelen;
          }
          if (thisPowerUp.type.equals("invincibility")) {
            invincible = false;
          }
          sps[thisPowerUp.soundFile].pause(true);
          thisPowerUp.activated = false;
        }
      }
    }
    if (thisPowerUp.age>0) {
      thisPowerUp.age-=1;
    }
  }
}

void resetPowerUps() {//at beginning of each level
  for (int i=0; i<powerUps.size(); i++) {
    PowerUp thisPowerUp = powerUps.get(i);
    for (int j=0; j<thisPowerUp.level_appearances.length; j++) {
      if (level.level == thisPowerUp.level_appearances[j] && !thisPowerUp.activated) {
        thisPowerUp.visible = true;
        thisPowerUp.activated_time = 1000;
        thisPowerUp.age = 1000;
      }
    }
  }
}
