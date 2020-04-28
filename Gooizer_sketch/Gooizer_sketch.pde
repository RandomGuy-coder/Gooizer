/**
*  Author: Tushar Mittal
*  Student id: 16123921
**/

import blobscanner.*;
import g4p_controls.*;
import netP5.*;
import oscP5.*;
import peasy.*;
import processing.video.*;
import java.awt.*;


boolean automaticSelected = false;
boolean calibrationComplete = false;  
boolean manualSelected = false;  
boolean pitchSelected = false;  
boolean playing = false;  //boolean keeps track if the sound is playing
boolean runAutomaticTimer = false;

color black = color(0,0,0);
color first;  //stores color of the first section
color second;  //stores color of the second section
color third;  //stores color of the third section
color white = color(255,255,255);

int calibrateColor;
int calibrated = 0;
int indexNumber = 0;
int thresholdVal = 25; //default value

final int PLAY_TIME = 32;

OscP5 oscP5;
NetAddress myRemoteLocation;
Capture video;
Detector bs;
private PImage processedImage;

/**
 * Initializes the program and sets up things that are important 
 * for the smooth operation of the program.
 */
public void setup() {
  
  size(320, 240, JAVA2D);
  createGUI();
  customGUI();
  disableButtons();
  
  //Netaddress and the port number at which pure data is listening
  oscP5 = new OscP5(this,12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 12001);
  
  //set up the camera for video capture. Change the camera name and fps as per your camera capabilities.
  video = new Capture(this, width, height,"iBall Face2Face CHD 12.0 Webca", 60);
  video.start();
  
  //processedImage is the buffer image created after processing the image from the camera
  processedImage = createImage(video.width, video.height, RGB);
  
  //initialize the blobscanner object for blob detection
  bs = new Detector(this, 0, 0, width, height, 255);
  
  log("Setup complete");
}

/**
 * Captures the image from the video
 */
void captureEvent(Capture video) {
  video.read();
}

/**
 * Processes the image captured and detectes the calibrated colors and outputs
 * the processed image.
 */
public void draw() {
  video.loadPixels();
  if(calibrated == 3) {
    
      image(video,0,0);
      loadPixels();
      processedImage.loadPixels();
      
      //maximum is the index of the last pixel
      int maximum = (video.width-1) + (video.height-1)*(video.width-1);
      
      //ratio is used to divide and process different sections for different colors
      int ratio = maximum/3;
      
      //processes each pixel of the image
      for(int x = 0; x < video.width; x++) {
        for(int y = 0; y < video.height; y++) {
        
        //loc is the index of the current pixel being processed
        int loc = x + y*video.width;
        
        //color of the current pixel
        color currentColor = video.pixels[loc];
        float r1 = red(currentColor);
        float g1 = green(currentColor);
        float b1 = blue(currentColor);
      
        float r2;
        float g2;
        float b2;
        
        //processing different colors for different sections
        if(loc <= ratio) {
          r2 = red(first);
          g2 = green(first);
          b2 = blue(first);
        } else if(loc > ratio && loc <= ratio*2) {
          r2 = red(second);
          g2 = green(second);
          b2 = blue(second);
        } else {
          r2 = red(third);
          g2 = green(third);
          b2 = blue(third);
        }
      
        //finds distance between the color of the current pixel and the color selected for that section
        float d = dist(r1,g1,b1,r2,g2,b2);
        
        //checks if the color is within the threshold value, if not then replaces with black color
        if(d < thresholdVal) {
          if(calibrationComplete) {
            //if calibration has been completed shows the processed areas as white
            processedImage.pixels[loc] = white;
          } else {
            processedImage.pixels[loc] = currentColor;
          }
        } else {
          processedImage.pixels[loc] = black;
        }
     }
     //displays the processedImage to the screen
     processedImage.updatePixels();
     image(processedImage,0,0);
   }
   //if calibration has been completed then processImageAndFindBlobs is called to process the blobs
   if(calibrationComplete) {
       log("Processing image to find blogs");
       processImageAndFindBlobs();
   }
 } else {
   image(video,0,0);
 }
 drawPartitionLines();
}

/**
 * Draw division lines to seperate the sections on the Gooizer screen
 */
void drawPartitionLines() {
  stroke(255);
  float y = video.height/3 - 1;
  float x1 = 0;
  float x2 = video.width - 1;
  for(int i = 1; i <= 2; i++) {
    line(x1,y*i,x2,y*i);
  }
}

/**
 * Draw division lines on the live feed screen and if pitch is selected 
 * also display the mid line for each section.
 * 
 * @param appc Applet of the window to update.
 */
void drawPartitionLines(PApplet appc) {
  liveFeedWindow.stroke(255);
  float y = video.height/3 - 1;
  float x1 = 0;
  float x2 = video.width - 1;
  for(int i = 1; i <= 2; i++) {
    appc.line(x1,y*i,x2,y*i);
  }
  if(pitchSelected){
    appc.stroke(100);
    y = y/2;
    for(int i = 1; i <=5;i = i+2){
      appc.line(x1,y*i,x2,y*i);
    }
  }
}

/**
 * This thread is created if the scanning is set to automatic.
 * Displays a countdown between scans and re-scans after the timer reaches 0.
 */
void timer(){
  int time = millis();
  int count = PLAY_TIME;
  while(runAutomaticTimer){
    if(millis() - time == 1000){
       count--;
       time = millis();
       timerField.setText("" + count);
       if(count == 0){
         runAutomaticTimer = false;
         sendMessage("/stop");
         redraw();
       }
    }
  }
}

/**
 * Detects the blobs from the processed image and for each blob sends to puredata the points on
 * the line connecting the most left, centroid and most right point of the blob.
 */
void processImageAndFindBlobs() {
 
  bs.imageFindBlobs(processedImage);
  bs.loadBlobsFeatures();
  bs.findCentroids();
  
  log("Number of blobs found " + bs.getBlobsNumber());
  
  float ratio = (video.height-1)/3;
  PVector[] edge;
  
  //stores the most left pixel of the blob
  PVector min;
  //stores the most right pixel of the blob
  PVector max;
  
  //process one blob at a time and send it's coordinates
  for(int i = 0; i < bs.getBlobsNumber(); i++) {
    edge = bs.getEdgePoints(i);
    min = new PVector(width,height);
    max = new PVector(0,0);
    
    for(int k = 0; k < edge.length; k++) {
      if(edge[k].x < min.x ) {
         min.x = edge[k].x;
         min.y = edge[k].y;
      } else if(edge[k].x > max.x) {
         max.x = edge[k].x;
         max.y = edge[k].y;
      }
    }
    
    //calulates the position of the blob using the centroid
    float centroidY = bs.getCentroidY(i);
    
    //find in which section the blob is located and send appropriate messages
    if(centroidY <= ratio) {
      log("Current Blob: " + i + " is in color1");

      min.y = ratio - min.y;
      max.y = ratio - max.y;
      float centreY = (ratio - centroidY) / ratio;
      float centreX = bs.getCentroidX(i);
            
      sendBlobCoordinates("/color1", min, max, centreX, centreY, ratio);
    } else if(centroidY > ratio && centroidY <= ratio*2) {
      log("Current Blob: " + i + " is in color2");
      
      min.y = ratio*2 - min.y;
      max.y = ratio*2 - max.y;
      float centreY = (ratio*2 - centroidY)/ratio;
      float centreX = bs.getCentroidX(i);
      
      sendBlobCoordinates("/color2", min, max, centreX, centreY, ratio);
    } else {
      log("Current Blob: " + i + " is in color3");
      
      min.y = ratio*3 - min.y;
      max.y = ratio*3 - max.y;
      float centreY = (ratio*3 - centroidY)/ratio;
      float centreX = bs.getCentroidX(i);
      
      sendBlobCoordinates("/color3", min, max, centreX, centreY, ratio);
    }
    
    //draw the contours of the blob
    bs.drawBlobContour(i,color(255,0,0),2);
  }
  //sends the play message after all blobs have been processed
  sendMessage("/play");
}

/**
 * Send coordinates of the blobs.
 
 * @param message The message to send with the coordinates.
 * @param min Most left coordinate of the blob.
 * @param max Most right coordiante of  the blob.
 * @param centreX X coordinate of the centroid.
 * @param centreY Y coordinate of the centroid.
 * @ratio the ratio of sections.
 */
void sendBlobCoordinates(String message, PVector min, PVector max, float centreX, float centreY, float ratio){
  log(min.x + " " + min.y + " " + max.x + " " + max.y);
  sendMessage(message, min.x, min.y/ratio);
  sendMissingPoints(message, min.x, min.y/ratio, centreX, centreY);
  sendMessage(message, centreX, centreY);
  sendMissingPoints(message, centreX, centreY, max.x, max.y/ratio);
  sendMessage(message, max.x, max.y/ratio);
}

/**
 * Calculates and sends the points on line connecting the given two points.
 *
 * @param message The message to send with the coordinates.
 * @param x1
 * @param y1
 * @param x2
 * @param y2
 */
void sendMissingPoints(String message, float x1, float y1, float x2, float y2) {
  float rate = 1/(x2-x1);
  float fixedRate = rate;
  println("Interpolating");
  for(int i = (int)x1+1; i < (int)x2; i++){
    sendMessage(message, i, lerp(y1, y2, rate));
    rate+= fixedRate;
  }
}

/**
 * Sends the message to the defined IP and port.
 * 
 * @param message
 */
void sendMessage(String message) {
  if(message.equals("/play")){
    playing = true;
    if(automaticSelected){
      runAutomaticTimer = true;
      thread("timer");
      log("Will wait " + PLAY_TIME + " seconds before reScan.");
    }
    println("playing");
  }else if(message.equals("/stop")){
    playing = false;
    indexNumber = 0;
    println("stopped");
  }
  OscMessage myOscMessage = new OscMessage(message);
  oscP5.send(myOscMessage, myRemoteLocation);
}

/**
 * Sends the coordinates to the defined IP and port.
 *
 * @param message
 * @param x
 * @param y
 */
void sendMessage(String message, float x, float y){
  OscMessage myOscMessage;
  myOscMessage = new OscMessage(message);
  myOscMessage.add(y);
  myOscMessage.add((int)x);
  oscP5.send(myOscMessage, myRemoteLocation);
}

/**
 * Disable the buttons so user cannot interact with them.
 */
void disableButtons(){
  scan.setVisible(false);
  stop.setVisible(false);
  automatic.setVisible(false);
  manual.setVisible(false);
}


void mouseClicked(){
  int loc = mouseX + mouseY*video.width;
  
  if(calibrateColor == 1){
     first = video.pixels[loc];
     calibrateColor = 0;
     calibrated++;
     log("Color 1 calibrated");
  }else if(calibrateColor == 2) {
     second = video.pixels[loc];
     calibrateColor = 0;
     calibrated++;
     log("Color 2 calibrated");
  }else if(calibrateColor == 3) {
     third = video.pixels[loc];
     calibrateColor = 0;
     calibrated++;
     log("Color 3 calibrated");
  }
}

void log(String toLog){
  println(hour() + ":" + minute() + ":" +second() + " :- " + toLog);
}

// Use this method to add additional statements
// to customise the GUI controls
public void customGUI(){

}
