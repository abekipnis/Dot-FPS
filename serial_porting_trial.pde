
//new serial porting trial
//  You always need to import the serial library in addition to the VSync library
import processing.serial.*;
import vsync.*;
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
Gain gsample1, gsample2;
WavePlayer[] wps;
Gain[] gains;
Gain synthGain;

String sourceFile, sourceFile2, sfs[];
Glide gainValue;
//  We create a new ValueReceiver to receive values from the arduino
ValueReceiver receiver;
//  This is the variable we want to sync from the Arduino to this sketch
public int slidervalue, loudness, xAxis, yAxis, zAxis, light, celsius, xValue, yValue, button, brightness;
public int button1, button2, button3, button4;
PFont f;
int loudnessmax=10;
int numsamples=3;
Dot dot;
int level =0;
void setup() 
{
  level=1;
  size(600, 600, P3D);
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

  sps=new SamplePlayer[numsamples];
  sfs=new String[numsamples];
  Function ringModulation = new Function(carrier, modulator)
  {
    public float calculate() {
      // multiply the value of modulator by
      // the value of the carrier
      return x[0] * x[1];
    }
  };
  sourceFile = sketchPath("") +
    "DrumMachine/sound_click_latch-24b.wav";
  for (int i=0; i<numsamples; i++) {
    switch(i) {
      case(0):
      {
        sfs[i]=sketchPath("")+"DrumMachine/sound_click_latch-24b.wav";
      }
      case(1):
      sfs[i]=sketchPath("")+"DrumMachine/20060__freqman__whip.wav";
    }
  }
  sourceFile2=sketchPath("")+ "DrumMachine/20060__freqman__whip.wav";
  g = new Gain(ac, 1, 0.5);
  g.addInput(ringModulation);
  ac.out.addInput(g);
  try {
    // initialize our SamplePlayer, loading the file
    // indicated by the sourceFile string
    sp1 = new SamplePlayer(ac, new Sample(sourceFile));
    sp2=new SamplePlayer(ac, new Sample(sourceFile2));
  }
  catch(Exception e)
  {
    // If there is an error, show an error message
    // at the bottom of the processing window.
    println("Exception while attempting to load sample!");
    e.printStackTrace(); // print description of the error
    exit(); // and exit the program
  }
  sp1.setKillOnEnd(false);
  sp2.setKillOnEnd(false);
  gainValue = new Glide(ac, 0.0, 20);
  gsample1 = new Gain(ac, 1, gainValue);
  gsample2 = new Gain(ac, 1, gainValue);
  gsample1.addInput(sp1); // connect the SamplePlayer to the Gain
  gsample2.addInput(sp2);
  ac.out.addInput(gsample1); // connect the Gain to the AudioContext
  ac.out.addInput(gsample2); // connect the Gain to the AudioContext


  ac.start(); // start audio processing


  dot = new Dot(width/2, height/2, 0, random(-1, 1), random(-1, 1), random(-1, 1));
  //  Hint: "/dev/ttyUSB0" is the serial port on my system. It might have
  //  a different name on yours. 
  //  It should be the same one that is checked under Tools->Serial Port in you Arduino IDE
  //  when uploading Arduino sketches.
  //  Look at http://processing.org/reference/libraries/serial/Serial.html if you still have trouble.
  Serial serial = new Serial(this, "/dev/tty.usbmodem411", 19200);
  //Serial serial = new Serial(this, "/dev/tty.usbmodem641", 19200);

  //  Ininialize the ValueReceiver with this (to hook it to your sketch)
  //  and the serial interface you want to use.
  receiver = new ValueReceiver(this, serial);
  // Tell the ValueReceiver what variable you want to synchronize from the arduino to this sketch.
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
  enemies=new Enemy[numenemies];
  gains= new Gain[numenemies];
  //old enemy array
  //for (int i =0; i<enemies.length; i++) {
  //  enemies[i]=new Enemy(random(width), random(height), -random(height), random(-1, 1), random(-1, 1), random(-1, 1));
  //}
  for (int i=0; i<numenemies; i++) {
    enemies2.add(new Enemy(random(width), random(height), -random(height), random(-1, 1), random(-1, 1), random(-1, 1)));
  }
}
//int numtimesforloudness;
Enemy[] enemies;
ArrayList<Enemy> enemies2 = new ArrayList<Enemy>();
int numenemies=10;
int deathcount=0;
int deadenemies=0;
ArrayList<Bullet> bullets = new ArrayList<Bullet>();
int numbullets=0;
void draw() 
{
    wps = new WavePlayer[numenemies];

  background(slidervalue/4, map(loudness, 0, 30, 0, 255), map(xAxis, -30, 30, 0, 255));
  //if (loudness>loudnessmax) {loudnessmax=loudness;}else{numtimesforloudness++;}
  //if(numtimesforloudness>20){loudnessmax=1;}
  //if (button1==1) {
  if ((map(xValue, -512, 512, 10, -10)<=2&&map(xValue, -512, 512, 10, -10)>=0)) {
  } else {
    // set the gain based on mouse position
    gainValue.setValue((float)dot.x/(float)width);
    // move the playback pointer to the first loop point (0.0)
    sp1.setToLoopStart();
    sp1.start();
    gainEnvelope.addSegment(0.8, 50); // over 50ms rise to 0.8
    gainEnvelope.addSegment(0.0, 300);
    bullets.add(new Bullet(dot.x, dot.y, dot.z, map(xValue, -512, 512, 10, -10), map(yValue, -512, 512, -10, 10), 0));
    numbullets++;
  }
  //}
  updatebullets();
  if (enemies2.size()!=0) {
    updateenemies();
    for (int i =0; i<enemies2.size(); i++) {
      wps[i]=new WavePlayer(ac, enemies2.get(i).x, Buffer.SINE);
    }
  }
  checkfornextlevel();
  carrierFrequency.setValue(dot.x+(map(xValue, -512, 512, 10, -10)));
  modulatorFrequency.setValue(dot.y+(map(yValue, -512, 512, 10, -10)));
  textFont(f, 20);
  fill(255);
  stroke(255);
  strokeWeight(2);
  text("death count: ", 10, 100);
  text(deathcount, 150, 100);
  text("dead enemies: ", 10, 150);
  text(deadenemies, 330, 150);
  text("number of enemies this level: ", 10, 200);
  text(numenemies, 330, 200);
  text("number of enemies left: ", 10, 250);
  text(enemies2.size(), 250, 250);
  text(frameCount/frameRate, 250, 300);
  text(level, 250, 50);
  println("loudness: ", loudness);
  println("light: ", light);
  println("celsius: ", celsius);
  println("xAxis: ", xAxis);
  println("yAxis: ", yAxis);
  println("zAxis: ", zAxis);
  println("xValue: ", xValue);
  println("vValue: ", yValue);
  println("button: ", button);
  println("button1: ", button1);
  println("button2: ", button2);
}