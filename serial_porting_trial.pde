//new serial porting trial
//  You always need to import the serial library in addition to the VSync library
import processing.serial.*;
import vsync.*;
import java.io.File;
// Ring_Modulation_01.pde
import beads.*; // import the beads library
AudioContext ac; // declare our AudioContext
// declare our unit generators
WavePlayer modulator;
Glide modulatorFrequency;
WavePlayer carrier;
SamplePlayer sp1, sp2, sps[];
Glide carrierFrequency;
Gain g; // our master gain
Envelope gainEnvelope;
OscillatorBank obank;
WavePlayer panLFO;
Panner p;
Gain gsamples;
Gain gsample1, gsample2, gains[];
WavePlayer[] wps;
Gain synthGain;
TapIn delayIn;
TapOut delayOut;
Gain delayGain;

int gridGranularity = 5;

GranularSamplePlayer gsp; 
Glide randomnessValue;
Glide grainSizeValue;
Glide positionValue;
Glide intervalValue;
Glide pitchValue;
Gain granularGain; // our usual master gain
Glide granularGainValue;


float sampleLength = 0;
String sourceFile, sourceFile2;
Glide gainValue, gainValues[];

//  We create a new ValueReceiver to receive values from the arduino
ValueReceiver receiver;
//  This is the variable we want to sync from the Arduino to this sketch
public int slidervalue, loudness, xAxis, yAxis, zAxis, light, celsius, xValue, yValue, button, brightness;
public int button1, button2, button3, button4;

PFont f;
int loudnessmax = 10;
int numsamples = 3;
int lostLifeFile, levelUpFile, themeFile, extraLifeFile, bulletFile;
//int level_, float minEnemyRadius_, float maxEnemyRadius_, float minEnemySpeed_, float maxEnemySpeed_
Level level = new Level(0, 5, 40, 1, 1);
File[] files, xplodefiles;
PImage[] xplode;
public int initNumLives = 1;
public color dotColor = color(30, 30, 30);
Serial serial;

int delayAfterDeathMillis = 2000;
ArrayList<PowerUp> powerUps = new ArrayList<PowerUp>();
PImage extra_life;
float[] sineWave;
Float[][] sincos = new Float[2][int(2*PI/.1)+1];
PShape[] flowerShapes;// = new PShape[width/2/20+1];
 int frac = 10;
void setup() 
{
  try {
    serial = new Serial(this, "/dev/tty.usbmodem411", 19200);
  } 
  catch (Exception e) {
  }
  size(600, 600, P3D);
  level.level = 0;
  //longer_bullet_appearances = {0,1,2,3,4};
  ac = new AudioContext();
  modulatorFrequency = new Glide(ac, 20, 30);
  modulator = new WavePlayer(ac, 
    modulatorFrequency, 
    Buffer.SINE);
  carrierFrequency = new Glide(ac, 20, 30);
  carrier = new WavePlayer(ac, 
    carrierFrequency, 
    Buffer.SINE);
  gainEnvelope = new Envelope(ac, 0.0);
  synthGain = new Gain(ac, 1, gainEnvelope);
  synthGain.addInput(carrier);
  ac.out.addInput(synthGain);
  obank = new OscillatorBank(ac, Buffer.SAW, numenemies);
  float data[] = {0.025};
  obank.setGains(data);
  ac.out.addInput(obank);

  //Function ringModulation = new Function(carrier, modulator)
  //{
  //  public float calculate() {
  //    // multiply the value of modulator by
  //    // the value of the carrier
  //    return x[0] * x[1];
  //  }
  //};
  g = new Gain(ac, 1, 0.5);
  //g.addInput(ringModulation);
  //panLFO = new WavePlayer(ac, 0.33, Buffer.SINE);
  //p = new Panner(ac, panLFO);
  //p.addInput(g);
  //ac.out.addInput(g);
  //ac.out.addInput(p);
  File xplodefilesdir = new File(sketchPath("")+"xplode_gif/");
  xplodefiles = xplodefilesdir.listFiles();
  File samplesdir = new File(sketchPath("")+"DrumMachine/");

  files = samplesdir.listFiles();
  String[] xfilenames = new String[xplodefiles.length];
  for (int i = 1; i < xplodefiles.length+1; i++) {
    xfilenames[i-1] = xplodefilesdir.toString()+"/xplode"+i+".png";
  }
  xplode = new PImage[xplodefiles.length];
  for (int i = 0; i < xplodefiles.length; i++) {
    println(xfilenames[i]);
    xplode[i] = loadImage(xfilenames[i].toString());
  }
  //PImage extra_life = new PImage();
  extra_life = loadImage(sketchPath("")+"powerUps/extra_life.png");

  sps = new SamplePlayer[files.length];
  gains = new Gain[files.length];
  gainValues = new Glide[files.length];

  delayIn = new TapIn(ac, 2000);
  delayOut = new TapOut(ac, delayIn, 200.0);
  delayGain = new Gain(ac, 1, 0.15);
  delayGain.addInput(delayOut);
  ac.out.addInput(delayGain);
  granularGainValue = new Glide(ac, 0.5, 100);
  granularGain = new Gain(ac, 1, gainValue);
  try {
    for (int i=0; i<files.length; i++) {
      println(i, files[i].toString(), files[i].getName());

      sps[i] = new SamplePlayer(ac, new Sample(files[i].toString()));
      sps[i].setKillOnEnd(false);
      gainValues[i] = new Glide(ac, 0.0);
      gainValues[i].setGlideTime(10);
      gainValues[i].setValue(0);
      gains[i] = new Gain(ac, 1, gainValues[i]);
      gains[i].addInput(sps[i]);// connect the SamplePlayer to the Gain
      delayIn.addInput(gains[i]);
      ac.out.addInput(gains[i]);// connect the Gain to the AudioContext
      if (files[i].getName().equals("lost_life.wav")) lostLifeFile = i;
      else if (files[i].getName().equals("sound_tab_retreat_level_up.wav")) levelUpFile = i;
      else if (files[i].getName().equals("extra_life.wav")) extraLifeFile = i;
      else if (files[i].getName().equals("theme.wav")) themeFile = i;
      else if (files[i].getName().equals("sound_tab_extend.wav")) bulletFile = i;
      else if (files[i].getName().equals("invincible.wav")) {
        gsp = new GranularSamplePlayer(ac, new Sample(files[i].toString()));
        sampleLength = (float)new Sample(files[i].toString()).getLength();
      }
    }
  }
  catch(Exception e)
  {
    // If there is an error, show an error message  
    // at the bottom of the processing window.
    println("Exception while attempting to load sample!");
    e.printStackTrace(); // print description of the error
    exit(); // and exit the program
  }

  randomnessValue = new Glide(ac, 80, 10);
  intervalValue = new Glide(ac, 100, 100);
  grainSizeValue = new Glide(ac, 100, 50);
  positionValue = new Glide(ac, 50000, 30);
  pitchValue = new Glide(ac, 1, 20);
  gsp.setGrainInterval(intervalValue);
  gsp.setGrainSize(grainSizeValue);
  gsp.setPosition(positionValue);
  gsp.setPitch(pitchValue);
  granularGain.addInput(gsp);
  gsp.start(); // start the granular sample player
  ac.out.addInput(granularGain);

  ac.start(); // start audio processing
  gainValues[themeFile].setValue(0.0);
  dot = new Dot(new PVector(width/2, height/2), new PVector(1, 1), initNumLives, dotColor, true);
  receiver = new ValueReceiver(this, serial);
  receiver.observe("slidervalue");
  receiver.observe("loudness");
  receiver.observe("xAxis");
  receiver.observe("yAxis");
  receiver.observe("zAxis");
  receiver.observe("light");
  receiver.observe("celsius");
  receiver.observe("xValue");
  receiver.observe("yValue");
  receiver.observe("button");
  receiver.observe("brightness");
  receiver.observe("button1");
  receiver.observe("button2");
  receiver.observe("button3");
  receiver.observe("button4");
  f = createFont("Arial", 16, true);
  initPowerUps();
  enemies = new Enemy[numenemies];
  for (int i=0; i<numenemies; i++) {
    //if (i==0) {
    //  enemies2.add(new Enemy(random(width), random(height), -random(height), random(-1, 1), random(-1, 1), random(-1, 1), dotColor, level.maxEnemyRadius, 5));
    //} else {
    enemies2.add(new Enemy(new PVector(random(width), random(height)), new PVector(random(level.maxEnemySpeed), random(level.maxEnemySpeed)), color(255,255,255), level.maxEnemyRadius, 5));
    //}
  }
  int maxsine = 50;
  sineWave = new float[maxsine];
  for (int i = 0; i < sineWave.length; i++) {
    // Fill array with values from sin()
    float r = map(i, 0, maxsine, 0, 5*TWO_PI);
    sineWave[i] = abs(sin(r));
  }
  for (float ang = 0; ang < 2*PI; ang+=.1) {
    sincos[0][int(ang/.1)] = cos(ang) + 1;
    sincos[1][int(ang/.1)] = sin(ang) + 1;
  }

  flowerShapes = new PShape[width/2/frac+1];
  for (int i=0; i<width/2; i+=20) {
    flowerShapes[i/frac] = createShape();
    flowerShapes[i/frac].setFill(color(255, i, i, 10));
    flowerShapes[i/frac].setStroke(color(255, 0, 0));
    flowerShapes[i/frac].beginShape();
    noiseSeed(i);
    for (float ang = 0; ang < 2*PI; ang+=.1) {
      //float xoff = ang) + 1;
      //float yoff = sin(ang) + 1;
      float rnew = map(noise(sincos[0][int(ang/.1)], sincos[1][int(ang/.1)]), 0, 1, i/2, i);
      //println(rnew);
      float newx = rnew*(sincos[0][int(ang/.1)]-1);
      float newy = rnew*(sincos[1][int(ang/.1)]-1);
      flowerShapes[i/frac].vertex(newx, newy);
    }
    flowerShapes[i/frac].endShape(CLOSE);
  }
}
//int numtimesforloudness;
Dot dot;
Enemy[] enemies;
ArrayList<Enemy> enemies2 = new ArrayList<Enemy>();
int numenemies = 1;
int deadenemies = 0;
ArrayList<Bullet> bullets = new ArrayList<Bullet>();
int numbullets = 0;
float xDirBullet;
float yDirBullet;
PVector normBulletVector, accel;
float bulletSpeed = 10;
float currMillis = 0;
float prevMillis = 0;
boolean paused = false;
public color mapcolor;
ArrayList<Explosion> currExplosions = new ArrayList<Explosion>();
boolean shooting = true;
Gain enemyGains[];
PVector joystick = new PVector();
int initBulletMaxLifetime = 45;
int bulletMaxLifetime = initBulletMaxLifetime;
boolean invincible = false;
float ang = 0;
void draw() 
{
  mapcolor = color(10*level.level, 15*level.level, 5*level.level);
  background(mapcolor);
  pushMatrix();
  translate(width/2, height/2);
  for (int i=0; i<width/2; i+=20) {  
    rotate(ang);//(((i/20%2==0) ? 1:-1)));
    shape(flowerShapes[i/frac], 0, 0);
  }
  popMatrix();
  ang+=.01;
  joystick.x = map(xValue, -512, 512, 100, -100);
  joystick.y = map(yValue, -512, 512, 100, -100);
  if (!(abs(joystick.x)>0 && abs(joystick.y)>2)) { //<>//
    //if the joystick has not moved, then make sure you can shoot again
    //shooting = true;
    sps[bulletFile].pause(true);
  } else {//if (frameCount%4==0) {
    //SHOOT BULLETS!!!!! //<>//
   shootBullets();
  }
  updatebullets();
  animateExplosions();
  animatePowerUps();
  updateenemies();
  dot.dotColor = blendColor(dot.dotColor, mapcolor, SUBTRACT);
  //carrierFrequency.setValue(map(dot.loc.x, 0, width, 100, 200));//+(map(xValue, -512, 208, 10, -10)));
  //modulatorFrequency.setValue(map(dot.loc.y, 0, height, 40, 80));//+(map(yValue, -512, 512, 10, -10)));
  textFont(f, 20);
  fill(blendColor(mapcolor, color(255, 255, 255), DIFFERENCE));
  stroke(blendColor(mapcolor, color(255, 255, 255), DIFFERENCE));
  strokeWeight(2);
  printStatus();
  dot = level.checkfornextlevel();
  //if (frameCount==0) {
  //  sps[themeFile].start();
  //}
  //currMillis = millis();
  grainSizeValue.setValue(abs(sqrt(2)*width/2-dot.loc.dist(new PVector(width/2, height/2))));
  //grainSizeValue.setValue((float)dot.loc.y/5+50);
  positionValue.setValue((float)((float)dot.loc.x / (float)width) * (sampleLength - 400));
  serial.write('0');
  //println("loudness: ", loudness);
  //println("light: ", light);
  //println("celsius: ", celsius);
  //println("xAxis: ", xAxis);
  //println("yAxis: ", yAxis);
  //println("zAxis: ", zAxis);
  //println("xValue: ", xValue);
  //println("vValue: ", yValue);
  //println("button: ", button);
  //println("button1: ", button1);
  //println("button2: ", button2);
}
public void keyPressed() {
  if (key == 's') {
    paused = !paused;
    if (paused) {
      noLoop();
    } else {
      loop();
    }
  }
}
public void shootBullets(){
      playSound(bulletFile, .9);
    normBulletVector = joystick.normalize();
    joystick.set(joystick.x, -joystick.y);
    color newBulletColor = lerpColor(color(57, 255, 20), color(255, 105, 180), map(numbullets, 0, 47, 0, 1));
    //color newBulletColor = color(random(255),random(255),random(255));
    bullets.add(new Bullet(dot.loc.copy(), normBulletVector.mult(bulletSpeed).copy().add(accel), newBulletColor, bulletMaxLifetime));
    numbullets = bullets.size();
}

public void printStatus(){
text("lives: ", 10, 100);
  text(dot.lives, 150, 100);
  text("dead enemies: ", 10, 150);
  text(deadenemies, 330, 150);
  text("number of enemies this level: ", 10, 200);
  text(numenemies, 330, 200);
  text("number of enemies left: ", 10, 250);
  text(enemies2.size(), 250, 250);
  //text(frameCount/frameRate, 250, 300);
  text(level.level, 250, 50);
  //text(numbullets, 300, 300);
  if (invincible) {
    text("you're invincible!", 300, 350);
    text(powerUps.get(1).activated_time, 500, 350);
  }
  if (powerUps.get(0).activated) {
    text("x2 lifetime bullets", 350, 400);
    text(powerUps.get(0).activated_time, 550, 400);
  }
}