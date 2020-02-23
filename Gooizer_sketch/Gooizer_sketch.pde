// Need G4P library
import g4p_controls.*;
import processing.video.*;
import blobscanner.*;
import peasy.*;

Capture video;

PImage processed;

boolean calibrationComplete = false;

color black = color(0,0,0);
color white = color(255,255,255);
color first;
color second;
color third;

int calibrated = 0;
int calibrate;
int thresholdVal;
int calibrateColor;

Detector bs;

public void setup(){
  size(320, 240, JAVA2D);
  createGUI();
  customGUI();
  thresholdVal = 25;
  
  String[] cameras = Capture.list();
  video = new Capture(this, 320,240,"USB Video Device", 30);
  video.start();
  
  processed = createImage(video.width, video.height, RGB);
  bs = new Detector(this,0,0,320,240,255);
  
}

void captureEvent(Capture video){
  video.read();
}

public void draw(){
  video.loadPixels();
  if(calibrated == 3){
      image(video,0,0);
      loadPixels();
      processed.loadPixels();
      
      int maximum = (video.width-1) + (video.height-1)*(video.width-1);
      int ratio = maximum/3;
      
      for(int x = 0; x < video.width; x++){
        for(int y = 0; y < video.height; y++){
        int loc = x + y*video.width;
           
        color currentColor = video.pixels[loc];
        float r1 = red(currentColor);
        float g1 = green(currentColor);
        float b1 = blue(currentColor);
      
        float r2;
        float g2;
        float b2;
      
        if(loc <= ratio){
          r2 = red(first);
          g2 = green(first);
          b2 = blue(first);
        }else if(loc > ratio && loc <= ratio*2){
          r2 = red(second);
          g2 = green(second);
          b2 = blue(second);
        }else{
          r2 = red(third);
          g2 = green(third);
          b2 = blue(third);
        }
      
        float d = dist(r1,g1,b1,r2,g2,b2);
        if(d < thresholdVal){
          if(calibrationComplete){
            processed.pixels[loc] = white;
          }else{
            processed.pixels[loc] = currentColor;
          }
        }else {
          processed.pixels[loc] = black;
        }
     }
     processed.updatePixels();
     image(processed,0,0);
     
     if(calibrationComplete){
       processImageAndFindBlobs();
     }
   }
 }else{
   image(video,0,0);
 }
}

void processImageAndFindBlobs(){
  processed.filter(THRESHOLD);
  bs.imageFindBlobs(processed);
  bs.loadBlobsFeatures();
     
  for(int i = 0; i < bs.getBlobsNumber(); i++){
     bs.drawBlobContour(i,color(255,0,0),2);
  }
}

void mouseClicked(){
  int loc = mouseX + mouseY*video.width;
  if(calibrate == 1){
     first = video.pixels[loc];
     calibrate = 0;
     calibrated++;
  }else if(calibrate == 2) {
     second = video.pixels[loc];
     calibrate = 0;
     calibrated++;
  }else if(calibrate == 3) {
     third = video.pixels[loc];
     calibrate = 0;
     calibrated++;
  }
}
// Use this method to add additional statements
// to customise the GUI controls
public void customGUI(){

}
