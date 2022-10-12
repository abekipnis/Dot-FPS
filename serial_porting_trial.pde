//new serial porting trial //<>// //<>// //<>//
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

int joystick0 =0;
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
boolean serialavailable=false;
void setup() 
{
  try {
    serial = new Serial(this, "/dev/tty.usbmodem141101", 19200);
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
    serialavailable=true;
  } 
  catch (Exception e) {
    println("Could not find a serial port controller! Using WASD keys for controls");
    xAxis = yAxis = xValue = yValue = slidervalue = loudness = light = celsius = button = brightness= 0; //have to initialize these values in case we're using WASD keys
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
  //obank = new OscillatorBank(ac, Buffer.SAW, numenemies);
  //float data[] = {0.025};
  //obank.setGains(data);
  //ac.out.addInput(obank);

  g = new Gain(ac, 1, 0.5);

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
      println(files[i].getName());
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

  // SOUND STUFF
  //randomnessValue = new Glide(ac, 80, 10);
  //intervalValue = new Glide(ac, 100, 100);
  //grainSizeValue = new Glide(ac, 100, 50);
  //positionValue = new Glide(ac, 50000, 30);
  //pitchValue = new Glide(ac, 1, 20);
  //gsp.setGrainInterval(intervalValue);
  //gsp.setGrainSize(grainSizeValue);
  //gsp.setPosition(positionValue);
  //gsp.setPitch(pitchValue);
  //granularGain.addInput(gsp);
  //gsp.start(); // start the granular sample player
  //ac.out.addInput(granularGain);
  //ac.start(); // start audio processing
  //gainValues[themeFile].setValue(0.0);
  
  // GAMEPLAY STUFF
  dot = new Dot(new PVector(width/2, height/2), new PVector(1, 1), initNumLives, dotColor, true);
  f = createFont("Arial", 16, true);
  initPowerUps();
  enemies = new Enemy[numenemies];
  for (int i=0; i<numenemies; i++) {
    //if (i==0) {
    //  enemies2.add(new Enemy(random(width), random(height), -random(height), random(-1, 1), random(-1, 1), random(-1, 1), dotColor, level.maxEnemyRadius, 5));
    //} else {
    enemies2.add(new Enemy(new PVector(random(width), random(height)), new PVector(random(level.maxEnemySpeed), random(level.maxEnemySpeed)), color(255, 255, 255), level.maxEnemyRadius, 5));
    //}
  }
  
  // SOUND STUFF
  //int maxsine = 50;
  //sineWave = new float[maxsine];
  //for (int i = 0; i < sineWave.length; i++) {
  //  // Fill array with values from sin()
  //  float r = map(i, 0, maxsine, 0, 5*TWO_PI);
  //  sineWave[i] = abs(sin(r));
  //}
  //for (float ang = 0; ang < 2*PI; ang+=.1) {
  //  sincos[0][int(ang/.1)] = cos(ang) + 1;
  //  sincos[1][int(ang/.1)] = sin(ang) + 1;
  //}
}

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
public PVector joystick = new PVector();
int initBulletMaxLifetime = 45;
int bulletMaxLifetime = initBulletMaxLifetime;
boolean invincible = false;
float ang = 0;

void drawbackground() {
  mapcolor = color(10*level.level, 15*level.level, 5*level.level);
  background(mapcolor);
  pushMatrix();
  translate(width/2, height/2);
  popMatrix();
}

void draw() 
{
  if (!serialavailable) {
    if (keyPressed) {
      if (key=='w') {
        yAxis-=1.5;
      } else if (key=='s') {
        yAxis+=1.5;
      } else if (key=='a') {
        xAxis+=1.5;
      } else if (key=='d') {
        xAxis-=1.5;
      }
    } 
    else {
      yAxis*=0.99;
      xAxis*=0.99;
    }
    if (mousePressed) {
      xValue = int(mouseX)-(int)dot.loc.x;
      yValue = (int)dot.loc.y-(int)mouseY;
    }
    else{
      xValue=yValue=0;
    }
  }
  gamestep();
  
}



public void shootBullets() {
  playSound(bulletFile, .5);
  normBulletVector = joystick.normalize();
  joystick.set(joystick.x, -joystick.y);
  color newBulletColor = lerpColor(color(57, 255, 20), color(255, 105, 180), map(numbullets, 0, 47, 0, 1));
  bullets.add(new Bullet(dot.loc.copy(), normBulletVector.mult(bulletSpeed).copy().add(accel), newBulletColor, bulletMaxLifetime));
  numbullets = bullets.size();
}
