class Dot {
  public PVector loc, vel, acc;
  float r;
  int lives;
  color dotColor;
  boolean alive;
  ArrayList<PVector> traceLoc;
  int tracelen, oldtracelen;
  PShape trace;
  PVector currloc;
  int gridLoc; 
  java.awt.Polygon p; 
  Dot(PVector loc_, PVector vel_, int lives_, color dotColor_, boolean alive_) {
    r = 20;
    this.loc = loc_;
    this.vel = vel_;
    gridLoc = 0;
    lives = lives_;
    dotColor = dotColor_;
    alive = alive_;
    tracelen = 45;
    traceLoc = new ArrayList<PVector>();
    p = new java.awt.Polygon();
  }
  void updateDot(PVector vel_) {
    acc = vel_;
    vel = vel.add(acc);//.setMag(10);
    //vel = vel_;
    this.loc = this.loc.add(vel_);
    //this.loc.set(this.loc.x+vel_.x, this.loc.y+vel_.y);
    traceLoc.add(loc.copy());
    if (traceLoc.size() > this.tracelen) {
      traceLoc.remove(0);
    }
    p.reset();
    for (int i = 0; i < traceLoc.size(); i++) {
      currloc = traceLoc.get(i).copy();
      p.addPoint(int(currloc.x), int(currloc.y));
    }
    p.addPoint(int(traceLoc.get(0).x), int(traceLoc.get(0).y));
    if (loc.x>width) {
      loc.set(0, loc.y);
      traceLoc.clear();
    }
    if (loc.x<0) {
      loc.set(width, loc.y);
      traceLoc.clear();
    }
    if (loc.y>height) {
      loc.set(loc.x, 0);
      traceLoc.clear();
    }
    if (loc.y<0) {
      loc.set(loc.x, height);
      traceLoc.clear();
    }
    gridLoc = int(loc.x)/int(width/gridGranularity) + gridGranularity*(-1+int(loc.y)/int(height/gridGranularity));

    drawDot();
  }
  void drawDot() {
    pushMatrix();
    trace = createShape();   
    trace.beginShape();
    for (int i = 0; i < traceLoc.size(); i++) {
      currloc = traceLoc.get(i).copy();
      trace.vertex(currloc.x, currloc.y);
    }
    trace.endShape();
    //trace.setFill(mapcolor);
    trace.setStroke(color(255, 0, 0));
    trace.setStroke(blendColor(dotColor, mapcolor, SUBTRACT));
    shape(trace, 0, 0);
    popMatrix();

    pushMatrix();
    translate(loc.x, loc.y);
    ellipse(0,0,20,20);
    float mag = acc.mag();
    float a = (acos(this.acc.x/mag)+PI);//%(2*PI);
    if (this.acc.y<0 && this.acc.x<0 || this.acc.y<0 && this.acc.x>0) {
      a = -a+PI;
    } 
    //else if () {
    //  a = -a+PI;
    //}
    rotate(a);
    fill(color(255, 0, 0));
    //fill(dotColor);
    stroke(dotColor);
    //for (int i = 0; i < sineWave.length; i+=5) {
    //  // Set stroke values to numbers read from array
    //  noFill();
    //  if(invincible) stroke(color(sineWave[i]*212, sineWave[i]*175, sineWave[i]*55));
    //  else stroke(sineWave[i] * 255);
    //  ellipse(0, 0, i+dot.r+10*mag, i+dot.r-6*mag);
    //}
    //ellipse(0, 0, r+10*mag, r-6*mag);
    //fill(blendColor(dotColor, color(level.level, numenemies, 150), ADD));
    fill(color(255, 0, 0));
    ellipse(0, 0, .5*r+5*mag, .8*r-3*mag);
    popMatrix();
  }
}
