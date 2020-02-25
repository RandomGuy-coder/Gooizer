import blobscanner.*;
import g4p_controls.*;
import netP5.*;
import oscP5.*;
import peasy.*;
import processing.video.*;

Capture video;

PImage processed;

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

public void setup(){
  size(320, 240, JAVA2D);
  createGUI();
  customGUI();
  thresholdVal = 25;
  oscP5 = new OscP5(this,12001);
  myRemoteLocation = new NetAddress("127.0.0.1", 12001);
  
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
     
     
   }
   if(calibrationComplete){
       processImageAndFindBlobs();
   }
 }else{
   image(video,0,0);
 }
 drawPartitionLines();
}

void drawPartitionLines(){
  stroke(255);
  int y = video.height/3 - 1;
  int x1 = 0;
  int x2 = video.width - 1;
  for(int i = 1; i <= 2; i++){
    line(x1,y*i,x2,y*i);
  }
}

void processImageAndFindBlobs(){
  processed.filter(THRESHOLD);
  bs.imageFindBlobs(processed);
  bs.loadBlobsFeatures();
  bs.findCentroids();
  float ratio = (video.height-1)/3;
  PVector[] edge;
  PVector min;
  PVector max;
  println(bs.getBlobsNumber());
  for(int i = 0; i < bs.getBlobsNumber(); i++){
    edge = bs.getEdgePoints(i);
    min = new PVector(width,height);
    max = new PVector(0,0);
    
    for(int k = 0; k < edge.length; k++){
       if(edge[k].x < min.x ){
         min.x = edge[k].x;
         min.y = edge[k].y;
    } else if(edge[k].x > max.x){
         max.x = edge[k].x;
         max.y = edge[k].y;
    }
    }
    stroke(255,0,0);
    float centroidY = bs.getCentroidY(i);
    if(centroidY <= ratio){
      min.y = ratio - min.y;
      max.y = ratio - max.y;
      sendMessage("color1", min.x, min.y);
      sendMessage("color1", bs.getCentroidX(i), ratio - centroidY);
      sendMessage("color1", max.x, max.y);
      println("color1");
    }else if(centroidY > ratio && centroidY <= ratio*2){
      point(min.x,min.y);
      point(min.x,min.y);
      point(bs.getCentroidX(i), centroidY);
      min.y = ratio*2 - min.y;
      max.y = ratio*2 - max.y;
      stroke(0,255,0);
      point(min.x,min.y);
      point(max.x,max.y);
      point(bs.getCentroidX(i), ratio*2 - centroidY);
      println("color2");
      println(min.x + " " + min.y + " " + max.x + " " + max.y);
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
      sendMessage("color3", min.x, min.y/ratio);
      sendMessage("color3", bs.getCentroidX(i), (ratio*3 - centroidY)/ratio);
      sendMessage("color3", max.x, max.y/ratio);
      println("color3");
      println(min.x + " " + min.y + " " + max.x + " " + max.y);
    }
  bs.drawBlobContour(i,color(255,0,0),2);
  }
  sendMessage("/play");
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
  println("sending " + x + " " + y);
    myOscMessage.add(y);
    myOscMessage.add(x);
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
// Use this method to add additional statements
// to customise the GUI controls
public void customGUI(){

}
