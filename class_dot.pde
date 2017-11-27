class Dot {
  float x, y, z,r;
  float vx, vy, vz;
  Dot(int x_, int y_, int z_, float vx_, float vy_, float vz_) {
    r=20;
    x=x_;
    y=y_;
    z=z_;
    vx=vx_;
    vy=vy_;
    vz=vz_;
  }
  void updateDot() {
    x=x+vx;
    y=y+vy;
  }
  void updateDot(float vx_, float vy_, float vz_) {
    x+=vx_;
    y+=vy_;
    //z+=vz_;
    //periodic boundary conditions
    if (x>width) {
      vx*=-1;
      x=0;
    }
    if (x<0) {
      //vx*=-1;
      x=width;
    }
    if (y>height) {
      y=0;
     // vy*=-1;
    }
    if (y<0) {
      y=height;
      //vy*=-1;
    }
    if (z>width) {
      z=0;
      //vz*=-1;
    }
    if (z<0) {
      z=width;
     // vz*=-1;
    }
  }
  void drawDot() {
    pushMatrix();
    translate(x, y, -z);
    fill(light);
    sphere(r);
    popMatrix();
  }
}