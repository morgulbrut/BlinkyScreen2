// Microphone to blink
//
// Can be controlled interactively using the keyboard
//
// W,w  - toggle waveform
// D,d  - toggle dots showing FFT
// A,a  - toggle some agent, controlled by the volume
// R,r  - toggle rotation, controlled by the volume
// S,s  - toggle dots and waveform
// Q,q  - switches all off, clear screen
// L,l  - toggle display of the led visualisation in the main window. Only for debuging
// 0,9  - set rotation to 0° or 90°
//
// 2018 Tillo Bosshart 
// Built on the shoulder of giants
// ------------------------
//
// Based off 
// Fancy FFT of the song
// Erin K 09/20/08
// RobotGrrl.com
// ------------------------
// Based off the code by Tom Gerhardt
// thomas-gerhardt.com


import processing.core.*;
import ddf.minim.analysis.*;
import ddf.minim.*;

AudioInput micIn;
FFT fftLog;

int sizew = 20;
int sizeh = 20;
float time = 0;
int timesteps = 1;
float rotval = 0.0;
boolean waveform, rotate, dots, agent, showLoc;
int highest=0;

int NORTH = 0;
int NORTHEAST = 1; 
int EAST = 2;
int SOUTHEAST = 3;
int SOUTH = 4;
int SOUTHWEST = 5;
int WEST = 6;
int NORTHWEST= 7;

float stepSize = 20;
float diameter = 20;

int direction;
float posX, posY;


Minim minim;

OPC opc;

void setup() {

  size(800, 400);
  background(0);
  minim = new Minim(this);
  micIn =  minim.getLineIn(Minim.MONO, 1024, 44100);
  fftLog = new FFT(micIn.bufferSize(), micIn.sampleRate());
  fftLog.logAverages(10, 3);
  fftLog.window(FFT.HAMMING);
  colorMode(HSB, 100);
  rotate = true;
  waveform = true;
  dots = false;
  agent=false;
  showLoc=false;
  posX = width/2;
  posY = height/2;

  opc = new OPC(this, "10.3.141.1", 7890);
  opc.ledGrid8x8(0 * 64, width * 1/8, height * 1/4, height/16, 0, false, false);
  opc.ledGrid8x8(1 * 64, width * 3/8, height * 1/4, height/16, 0, false, false);
  opc.ledGrid8x8(2 * 64, width * 5/8, height * 1/4, height/16, 0, false, false);
  opc.ledGrid8x8(3 * 64, width * 7/8, height * 1/4, height/16, 0, false, false);
  opc.ledGrid8x8(4 * 64, width * 1/8, height * 3/4, height/16, 0, false, false);
  opc.ledGrid8x8(5 * 64, width * 3/8, height * 3/4, height/16, 0, false, false);
  opc.ledGrid8x8(6 * 64, width * 5/8, height * 3/4, height/16, 0, false, false);
  opc.ledGrid8x8(7 * 64, width * 7/8, height * 3/4, height/16, 0, false, false);

  opc.showLocations(showLoc);
}

void draw() {
  time += 0.2;
  fftLog.forward(micIn.mix);
  ellipseMode(CENTER);
  smooth();
  noStroke();
  colorMode(RGB, 100);

  fill(color(0, 0, 0, 1));

  rect(0, 0, width, height);
  filter(BLUR, 1);

  colorMode(HSB, 100);

  if (rotate) {
    rotval += micIn.left.level()/5;
  }
  translate(width/2, height/2);
  rotate(rotval);
  translate(-width/2, -height/2);

  if (agent) {
    highest=0;
    for (int n = 0; n < fftLog.specSize (); n++) {
      // draw the line for frequency band n, scaling it by 4 so we can see it a bit better
      line(n, height, n, height - fftLog.getBand(n));

      //find frequency with highest amplitude
      if (fftLog.getBand(n)>fftLog.getBand(highest))
        highest=n;
    }
    for (int i = 0; i < 500*micIn.left.level (); i++) {
      direction = (int) random(0, 8);

      if (direction == NORTH) {  
        posY -= stepSize;
      } else if (direction == NORTHEAST) {
        posX += stepSize;
        posY -= stepSize;
      } else if (direction == EAST) {
        posX += stepSize;
      } else if (direction == SOUTHEAST) {
        posX += stepSize;
        posY += stepSize;
      } else if (direction == SOUTH) {
        posY += stepSize;
      } else if (direction == SOUTHWEST) {
        posX -= stepSize;
        posY += stepSize;
      } else if (direction == WEST) {
        posX -= stepSize;
      } else if (direction == NORTHWEST) {
        posX -= stepSize;
        posY -= stepSize;
      }

      if (posX > width) posX = 0;
      if (posX < 0) posX = width;
      if (posY < 0) posY = height;
      if (posY > height) posY = 0;

      fill((time+20)%100+random(15), 100, 100, 20);
      ellipse(posX+stepSize/2, posY+stepSize/2, diameter, diameter);
    }
  }

  if (waveform) {
    stroke(color(time%100+random(15), 100, 100, 60));
    for (int i = 0; i < micIn.bufferSize () - 1; i++)
    {
      line(400 + micIn.right.get(i)*500, i-300, 400 + micIn.right.get(i+1)*500, i-299);
    }
    noStroke();
  }

  if (dots) {
    for (int i = 0; i < fftLog.avgSize (); i++) {         

      float amp = sqrt(sqrt(fftLog.getAvg(i)))*height/2;
      float h = i * 100/fftLog.avgSize();
      h -= 10;
      h = 100 - h;
      float s = 70;
      float b = amp/3 * 100;
      float a = 50;
      fill(color(h+random(-20, 20), s, b, a));
      float x = i*width/fftLog.avgSize();
      float y = height - amp-50;
      ellipse(x+random(4), y, sizew, sizeh);
    }
  }
}

void exit(){
    println("Closing sketch");
    micIn.close();
    super.exit();
}

void clearScreen() {
  dots = false;
  waveform = false;
  agent = false;
  rotate = false;
  rotval = 0.0;
  background(0);
}

void keyPressed() {
  if (key == CODED) {
  } else if (key == 'W'||key == 'w') { 
    waveform = !waveform;
  } else if (key == 'R'||key == 'r') {
    rotate = !rotate;
  } else if (key == 'D'||key == 'd') {
    dots = !dots;
  } else if (key == 'S'||key == 's') {
    dots = !dots;
    waveform = !waveform;
  } else if (key == 'Q'||key == 'q') {
    clearScreen();
  } else if (key == 'A'||key == 'a') {
    agent = !agent;
  } else if (key == '0') {
    rotval = 0.0;
  } else if (key == '9') {
    rotval = HALF_PI;
  } else if (key == 'L' |key == 'l') {
    showLoc = !showLoc;
    opc.showLocations(showLoc);
  }
}
