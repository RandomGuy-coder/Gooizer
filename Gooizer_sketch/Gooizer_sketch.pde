import blobscanner.*;
import g4p_controls.*;
import netP5.*;
import oscP5.*;
import peasy.*;
import processing.video.*;

Capture video;

PImage processedImage;

boolean calibrationComplete = false;

Detector bs;

color black = color(0,0,0);
color first;
color second;
color third;
color white = color(255,255,255);

int calibrate;
int calibrateColor;
int calibrated = 0;
int thresholdVal;

OscP5 oscP5;
NetAddress myRemoteLocation;

public void setup() {
  size(320, 240, JAVA2D);
  createGUI();
  customGUI();
  thresholdVal = 25;
  
  //Netaddress and the port number at which pure data is listening
  oscP5 = new OscP5(this,12001);
  myRemoteLocation = new NetAddress("127.0.0.1", 12001);
  
  //set up the camera to the camera name
  String[] cameras = Capture.list();
  video = new Capture(this, 320,240,"USB Video Device", 30);
  video.start();
  
  //processedImage is the buffer image created after processing the image from the camera
  processedImage = createImage(video.width, video.height, RGB);
  
  bs = new Detector(this,0,0,320,240,255);
  
  log("Setup complete");
}

//Captures the image from the video
void captureEvent(Capture video) {
  video.read();
}

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
        
        //checks with the threshold and decides if the pixel should be ignored
        if(d < thresholdVal) {
          if(calibrationComplete){
            processedImage.pixels[loc] = white;
          } else {
            processedImage.pixels[loc] = currentColor;
          }
        } else {
          processedImage.pixels[loc] = black;
        }
     }
     processedImage.updatePixels();
     image(processedImage,0,0);
   }
   //if calibration has been completed then processImageAndFindBlobs is called to process the blobs
   if(calibrationComplete) {
       log("Processing image to find blogs");
       processImageAndFindBlobs();
   }
 }else {
   image(video,0,0);
 }
 //draw the lines to divide the three sections. So, it's easier to set up gooizer
 drawPartitionLines();
}

//draws line to divide sections
void drawPartitionLines() {
  stroke(255);
  int y = video.height/3 - 1;
  int x1 = 0;
  int x2 = video.width - 1;
  for(int i = 1; i <= 2; i++) {
    line(x1,y*i,x2,y*i);
  }
}

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
    
    //calculate and send different message for different colors
    if(centroidY <= ratio) {
      min.y = ratio - min.y;
      max.y = ratio - max.y;
      sendMessage("color1", min.x, min.y);
      sendMessage("color1", bs.getCentroidX(i), ratio - centroidY);
      sendMessage("color1", max.x, max.y);
      println("color1");
    } else if(centroidY > ratio && centroidY <= ratio*2) {
      min.y = ratio*2 - min.y;
      max.y = ratio*2 - max.y;
      stroke(0,255,0);
      point(min.x,min.y);
      point(max.x,max.y);
      point(bs.getCentroidX(i), ratio*2 - centroidY);
      log("Current Blob:" + i + "is in color2");
      log(min.x + " " + min.y + " " + max.x + " " + max.y);
      sendMessage("color2", min.x, min.y/ratio);
      sendMessage("color2", bs.getCentroidX(i), (ratio*2 - centroidY)/ratio);
      sendMessage("color2", max.x, max.y/ratio);
    }else{
      min.y = ratio*3 - min.y;
      max.y = ratio*3 - max.y;
      stroke(0,0,255);
      point(min.x,min.y);
      point(max.x,max.y);
      point(bs.getCentroidX(i), ratio*3 - centroidY);
      log("Current Blob:" + i + "is in color3");
      println(min.x + " " + min.y + " " + max.x + " " + max.y);
      sendMessage("color3", min.x, min.y/ratio);
      sendMessage("color3", bs.getCentroidX(i), (ratio*3 - centroidY)/ratio);
      sendMessage("color3", max.x, max.y/ratio);
    }
  //draw the contours of the blobs
  bs.drawBlobContour(i,color(255,0,0),2);
  }
  //sends the message to play the sound after all blobs have been processed
  sendMessage("/play");
}

void sendMissingPoints(String colorType, float x1, float x2, float y) {
  for(int i = (int)x1+1; i < (int)x2; i++){
    sendMessage(colorType, i,y);
  }
}

void sendMessage(String message) {
  OscMessage myOscMessage = new OscMessage(message);
  oscP5.send(myOscMessage, myRemoteLocation);
}

void sendMessage(String colorType, float x, float y){
  
  OscMessage myOscMessage;
  
  if(colorType.equals("color1")) {
    myOscMessage = new OscMessage("/color1");
  } else if(colorType.equals("color2")){
    myOscMessage = new OscMessage("/color2");
  } else{
    myOscMessage = new OscMessage("/color3");
  }
  log("sending " + (int)x + " " + y);
  myOscMessage.add(y);
  myOscMessage.add((int)x);
  oscP5.send(myOscMessage, myRemoteLocation);
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

void log(String toLog){
  println(hour() + ":" + minute() + ":" +second() + " :- " + toLog);
}
// Use this method to add additional statements
// to customise the GUI controls
public void customGUI(){

}
