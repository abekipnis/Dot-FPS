class Bullet {
  float x, y, z;
  float vx, vy, vz;
  int lifetime;
  Bullet(float x_, float y_, float z_, float vx_, float vy_, float vz_) {
    x=x_;
    y=y_;
    z=z_;
    vx=vx_+.001*dot.x;
    vy=vy_+.001*dot.y;
    vz=vz_+.001*dot.z;
  }
  void updateBullet() {
    x=x+vx+.001*dot.x;
    y=y+vy+.001*dot.y;
  }
  void updateBullet(float vx_, float vy_, float vz_) {
    lifetime++;
    x+=vx_+.001*dot.x;
    y+=vy_+.001*dot.y;
    //z+=vz_;
    //periodic boundary conditions
  }
  void drawBullet() {
    pushMatrix();
    // translate(0, 0, -z);
    line(x, y, x+vx, y+vy);
    popMatrix();
  }
}
void updatebullets() {
  Bullet currentbullet;
  for (int i=0; i<bullets.size(); i++) {
    currentbullet=bullets.get(i);
    if (currentbullet.lifetime>25) {
      bullets.remove(currentbullet);
    }
    currentbullet.updateBullet();
    currentbullet.drawBullet();
  }
}