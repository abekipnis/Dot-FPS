// Granular_01.pde
// In this granular synthesis demonstration, the mouse
// controls the position and grain size parameters. The
// position within the source audio file is controlled by
// the X-axis. The grain size is controlled by the Y-axis.
import beads.*; // import the beads library
AudioContext ac; // declare our parent AudioContext
// what file will be granulated?
String sourceFile = "invincible.wav";
Gain masterGain; // our usual master gain
GranularSamplePlayer gsp; // our GranularSamplePlayer object
// these// unit generators will be connected to various
//granulation parameters
Glide gainValue;
Glide randomnessValue;
Glide grainSizeValue;
Glide positionValue;
Glide intervalValue;
Glide pitchValue;
// this object will hold the audio data that will be
// granulated
Sample sourceSample = null;
// this float will hold the length of the audio data, so that
// we don't go out of bounds when setting the granulation
// position
float sampleLength = 0;
void setup()
{
 size(800, 600); // set a reasonable window size

 ac = new AudioContext(); // initialize our AudioContext
 // again, we encapsulate the file-loading in a try-catch
 // block, just in case there is an error with file access
 try {
 // load the audio file which will be used in granulation
 sourceSample = new Sample(sketchPath("") + sourceFile);
 }
 // catch any errors that occur in file loading
 catch(Exception e) {
 println("Exception while attempting to load sample!");
 e.printStackTrace();
 exit();
 }
 // store the sample length - this will be used when
 // determining where in the file we want to position our
 // granulation pointer
 sampleLength = (float)sourceSample.getLength();
 // set up our master gain
 gainValue = new Glide(ac, 0.5, 100);
 masterGain = new Gain(ac, 1, gainValue);
 // initialize our GranularSamplePlayer
 gsp = new GranularSamplePlayer(ac, sourceSample);
 randomnessValue = new Glide(ac, 80, 10);
 intervalValue = new Glide(ac, 100, 100);
 grainSizeValue = new Glide(ac, 100, 50);
 positionValue = new Glide(ac, 50000, 30);
 pitchValue = new Glide(ac, 1, 20);
 // connect all of our Glide objects to the previously
 // created GranularSamplePlayer
 //gsp.setRandomness(randomnessValue);
 gsp.setGrainInterval(intervalValue);
 gsp.setGrainSize(grainSizeValue);
 gsp.setPosition(positionValue);
 gsp.setPitch(pitchValue);
 // connect our GranularSamplePlayer to the master gain
 masterGain.addInput(gsp);
 gsp.start(); // start the granular sample player

 ac.out.addInput(masterGain);
 ac.start(); // begin audio processing
 background(0); // set the background to black
 text("Move the mouse to control granular synthesis.",
 100, 120); // tell the user what to do!
}
// the main draw function
void draw()
{
 background(0, 0, 0);
 // grain size can be set by moving the mouse along the Y-
 // axis
 grainSizeValue.setValue((float)mouseY/5+50);
 positionValue.setValue((float)((float)mouseX / (float)width) * (sampleLength - 400));
}