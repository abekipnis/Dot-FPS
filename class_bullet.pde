class Bullet {
  public PVector loc, vel;
  int lifetime;
  int maxlife;
  int bounces;
  color bulletColor;
  Bullet(PVector loc_, PVector vel_, color bulletColor_,int maxlife_) {
    this.loc = loc_;
    this.vel = vel_;
    bounces = 0;
    bulletColor = bulletColor_;
    maxlife = maxlife_;
  }
  void updateBullet(Bullet b, int i) {
    lifetime++;
    b.loc = b.loc.add(b.vel);
    //this.loc.set(this.loc.x+this.vel.x, this.loc.y+this.vel.y);//+.001*dot.x;
    //loc.x = loc.x+vel.x;//+.001*dot.x;
    //loc.y = loc.y+vel.y;//+.001*dot.y;
    if (b.loc.x>=width) {
      bounces ++;
      b.vel.x*=-1;
    }
    if (b.loc.x<=0) {
      bounces ++;
      b.vel.x*=-1;
    }
    if (b.loc.y>=height) {
      bounces ++;
      b.vel.y*=-1;
    }
    if (b.loc.y<=0) {
      bounces ++;
      b.vel.y*=-1;
    }
    drawBullet(b, i);
  }
  //void updateBullet(PVector vel_) {
  //  lifetime++;
  //  this.loc.set(this.loc.x+vel_.x, this.loc.y+vel_.y);//+.001*dot.x;
  //  //z+=vz_;
  //  //periodic boundary conditions
  //}
  void drawBullet(Bullet b, int i) {
    pushMatrix();
    // translate(0, 0, -z);255-105-180 = hot pink
    color from = color(0, 0, 0);
    color to = color(255, 105, 180);
    //stroke(blendColor(color(map(i+1,0,bullets.size(),0,255),map(i+1,0,bullets.size(),0,105),map(i+1,0,bullets.size(),0,180)),mapcolor,SUBTRACT));
    stroke(bulletColor);
    //stroke(lerpColor(from,to,map(i+1,1,bullets.size(),0,1)));
    line(b.loc.x-b.vel.x, b.loc.y-b.vel.y, b.loc.x, b.loc.y);
    translate(b.loc.x, b.loc.y);
    stroke(bulletColor);
    ellipse(0, 0, 3, 3);
    popMatrix();
  }
}
void updatebullets() {
  Bullet currentbullet;
  for (int i=0; i<bullets.size(); i++) {
    currentbullet = bullets.get(i);
    if (currentbullet.lifetime > currentbullet.maxlife || currentbullet.bounces > 2) {// || currentbullet.x<0 || currentbullet.x>width || currentbullet.y<0 || currentbullet.y>height) {
      bullets.remove(currentbullet);
    }
    currentbullet.updateBullet(currentbullet,i);
    //currentbullet.drawBullet();
  }
}