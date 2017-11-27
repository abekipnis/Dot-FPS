#include <VSync.h>
#include <Esplora.h>

//  Create a new sender here
//  Put the number of variables you want to sync in the pointy brackets
//  Here we just want to sync one value
ValueSender<12> sender;

//  here we store the value we read from analog bin A0
int slidervalue,loudness,xAxis,yAxis,zAxis,light,celsius,xValue,yValue,button,brightness;
int button1,button2,button3,button4;
int lightMin = 1023;        // minimum sensor value
int lightMax = 0;           // maximum sensor value
boolean calibrated = false;  // whether the sensor's been calibrated yet

void setup()
{
  //  You need to call Serial.begin() in order for value syncing to work.
  //  Make sure to use the same baudrate on both ends. More baud = more speed
  Serial.begin(19200);
  //  Tell the sending syncronizer what variable needs to be kept in sync.
  //  In this case it is just the variable 'analogValue' but if you sync more,
  //  you need to make sure to use the same order on the sending and the receiving side.
  sender.observe(slidervalue);
  sender.observe(loudness);
  sender.observe(xAxis);
  sender.observe(yAxis);
  sender.observe(zAxis);
  sender.observe(light);
  sender.observe(celsius);
  sender.observe(xValue);
    sender.observe(yValue);
    sender.observe(button);
  sender.observe(brightness);
  sender.observe(button1);
    sender.observe(button2);
  sender.observe(button3);
  sender.observe(button4);
}
void loop()
{
  if (Esplora.readButton(1) == LOW) {
    calibrate();
  }
  // Read a value from analog pin A0. You could hook up a LDR or a potmeter.
  slidervalue = Esplora.readSlider();
  loudness = Esplora.readMicrophone();
  xAxis = Esplora.readAccelerometer(X_AXIS);    // read the X axis
  yAxis = Esplora.readAccelerometer(Y_AXIS);    // read the Y axis
  zAxis = Esplora.readAccelerometer(Z_AXIS);
  light = Esplora.readLightSensor();
  brightness = map(light, lightMin, lightMax, 0, 255);
  brightness = constrain(brightness, 0, 255);
  celsius = Esplora.readTemperature(DEGREES_C);
  xValue = Esplora.readJoystickX();        // read the joystick's X position
  yValue = Esplora.readJoystickY();        // read the joystick's Y position
  button = Esplora.readJoystickSwitch();
  while(Esplora.readButton(1) == LOW) {
    button1=1;
  }
  while(Esplora.readButton(2) == LOW) {
    button2=1;
  }
  while(Esplora.readButton(3) == LOW) {
    button3=1;
  }
  while(Esplora.readButton(4) == LOW) {
    button4=1;
  }
  //  You need to call sync() for once every loop.
  //  It does not matter where you call it but for the ValueSender
  //  it makes sense at the end.
  sender.sync();
  //delay(10); 
}
void calibrate() {
  // tell the user what do to using the serial monitor:
  //Serial.println("While holding switch 1, shine a light on the light sensor, then cover it.");
  // calibrate while switch 1 is pressed:
  while(Esplora.readButton(1) == LOW) {
    // read the sensor value: 
    int light  = Esplora.readLightSensor();
    // record the maximum sensor value:
    if (light > lightMax) {
      lightMax = light;
    }
    // record the minimum sensor value:
    if (light < lightMin) {
      lightMin = light;
    }
    // note that you're calibrated, for future reference:
    calibrated = true;
  }
}





