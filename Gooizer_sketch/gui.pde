/* =========================================================
 * ====                   WARNING                        ===
 * =========================================================
 * The code in this tab has been generated from the GUI form
 * designer and care should be taken when editing this file.
 * Only add/edit code inside the event handlers i.e. only
 * use lines between the matching comment tags. e.g.

 void myBtnEvents(GButton button) { //_CODE_:button1:12356:
     // It is safe to enter your event code here  
 } //_CODE_:button1:12356:
 
 * Do not rename this tab!
 * =========================================================
 */

synchronized public void win_draw1(PApplet appc, GWinData data) { //_CODE_:controls_window:756554:
  appc.background(230);
  
  //scan and stop with keys only works in manual mode
  if(appc.keyPressed){
    if(manualSelected){
      if(appc.key == 'S' || appc.key == 's'){
        log("Scan button pressed");
        sendMessage("/stop");
        redraw();
      }else if(appc.key == 'E' || appc.key == 'e'){
        log("Stop button pressed");
        sendMessage("/stop");
      }
    }
  }
} //_CODE_:controls_window:756554:

public void threshold_change(GSlider source, GEvent event) { //_CODE_:threshold:411244:
  log("Threshold changed to value" + source.getValueI());
  thresholdVal = source.getValueI();
} //_CODE_:threshold:411244:

public void scan_event(GButton source, GEvent event) { //_CODE_:scan:596391:
  log("Scan button pressed");
  sendMessage("/stop");
  redraw();
} //_CODE_:scan:596391:

public void calibrate1_click1(GButton source, GEvent event) { //_CODE_:calibrate1:837833:
  log("Calibrate color 1 button pressed");
  calibrateColor = 1;
} //_CODE_:calibrate1:837833:

public void calibrate2_click1(GButton source, GEvent event) { //_CODE_:calibrate2:893355:
  log("Calibrate color 2 button pressed");
  calibrateColor = 2;
} //_CODE_:calibrate2:893355:

public void calibrate3_click1(GButton source, GEvent event) { //_CODE_:calibrate3:200157:
  log("Calibrate color 3 button pressed");
  calibrateColor = 3;
} //_CODE_:calibrate3:200157:

public void stop_event(GButton source, GEvent event) { //_CODE_:stop:741613:
  log("Stop button pressed");
  sendMessage("/stop");
} //_CODE_:stop:741613:

public void finalize_calibration(GButton source, GEvent event) { //_CODE_:finalizeCalibration:715230:
  if(!calibrationComplete){
    log("Finalize calibration pressed");
    noLoop();
    delay(1000);
    calibrationComplete = true;
    automatic.setVisible(true);
    manual.setVisible(true);
    calibrate1.setEnabled(false);
    calibrate2.setEnabled(false);
    calibrate3.setEnabled(false);
    source.setText("Recalibrate");
  }else{
    calibrationComplete = false;
    calibrated = 0;
    automatic.setVisible(false);
    manual.setVisible(false);
    scan.setVisible(false);
    stop.setVisible(false);
    calibrate1.setEnabled(true);
    calibrate2.setEnabled(true);
    calibrate3.setEnabled(true);
    loop();
    source.setText("Finalize Calibration");
  }
} //_CODE_:finalizeCalibration:715230:

public void automatic_click(GButton source, GEvent event) { //_CODE_:automatic:878699:
  sendMessage("/stop");
  delay(1000);
  log("Automatic Selected");
  redraw();
  timerField.setFont(new Font("Monospaced", Font.PLAIN,45));
  automaticSelected = true;
  manualSelected = false;
  scan.setVisible(false);
  stop.setVisible(false);
  automatic.setEnabled(false);
  manual.setEnabled(true);
} //_CODE_:automatic:878699:

public void manual_click(GButton source, GEvent event) { //_CODE_:manual:377157:
  log("Manual Selected");
  scan.setVisible(true);
  stop.setVisible(true);
  manualSelected = true;
  automaticSelected = false;
  runAutomaticTimer = false;
  sendMessage("/stop");
  automatic.setEnabled(true);
  manual.setEnabled(false);
} //_CODE_:manual:377157:

public void timerField_change1(GTextField source, GEvent event) { //_CODE_:timerField:785677:
  println("textfield1 - GTextField >> GEvent." + event + " @ " + millis());
} //_CODE_:timerField:785677:

public void amplitude_click(GButton source, GEvent event) { //_CODE_:amplitude:647434:
  log("Amplitude has been selected");
  sendMessage("/amplitude");
  pitchSelected = false;
} //_CODE_:amplitude:647434:

public void pitch_click(GButton source, GEvent event) { //_CODE_:pitch:524892:
  log("Pitch has been selected");
  sendMessage("/pitch");
  pitchSelected = true;
} //_CODE_:pitch:524892:

synchronized public void live_feed_draw(PApplet appc, GWinData data) { //_CODE_:liveFeedWindow:222651:
  //Draws line on screen depending on which x value is being read at that time.
  if(calibrationComplete){
    appc.image(video,0,0);
    drawPartitionLines(appc);
    if(playing){
        if(indexNumber == (PLAY_TIME*10)-1){
          indexNumber = 0;
        }else{
          appc.stroke(255);
          appc.line(indexNumber, 0, indexNumber, video.height-1);
          if(appc.frameCount%12 ==0){
            indexNumber++;
          }
        }
    }
  }
} //_CODE_:liveFeedWindow:222651:



// Create all the GUI controls. 
// autogenerated do not edit
public void createGUI(){
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setMouseOverEnabled(false);
  surface.setTitle("Gooizer");
  controls_window = GWindow.getWindow(this, "controls", 0, 300, 480, 320, JAVA2D);
  controls_window.noLoop();
  controls_window.setActionOnClose(G4P.KEEP_OPEN);
  controls_window.addDrawHandler(this, "win_draw1");
  threshold = new GSlider(controls_window, 79, 20, 300, 40, 10.0);
  threshold.setShowValue(true);
  threshold.setShowLimits(true);
  threshold.setLimits(25, 0, 255);
  threshold.setNumberFormat(G4P.INTEGER, 0);
  threshold.setOpaque(false);
  threshold.addEventHandler(this, "threshold_change");
  scan = new GButton(controls_window, 265, 87, 80, 30);
  scan.setText("Scan");
  scan.addEventHandler(this, "scan_event");
  calibrate1 = new GButton(controls_window, 84, 86, 80, 30);
  calibrate1.setText("Calibrate Color 1");
  calibrate1.addEventHandler(this, "calibrate1_click1");
  calibrate2 = new GButton(controls_window, 83, 124, 80, 30);
  calibrate2.setText("Calibrate Color 2");
  calibrate2.addEventHandler(this, "calibrate2_click1");
  calibrate3 = new GButton(controls_window, 82, 162, 80, 30);
  calibrate3.setText("Calibrate Color 3");
  calibrate3.addEventHandler(this, "calibrate3_click1");
  stop = new GButton(controls_window, 265, 124, 81, 32);
  stop.setText("Stop");
  stop.addEventHandler(this, "stop_event");
  finalizeCalibration = new GButton(controls_window, 81, 202, 80, 30);
  finalizeCalibration.setText("Finalize Calibration");
  finalizeCalibration.addEventHandler(this, "finalize_calibration");
  automatic = new GButton(controls_window, 175, 87, 80, 30);
  automatic.setText("Automatic");
  automatic.addEventHandler(this, "automatic_click");
  manual = new GButton(controls_window, 174, 124, 80, 30);
  manual.setText("Manual");
  manual.addEventHandler(this, "manual_click");
  timerField = new GTextField(controls_window, 371, 228, 75, 63, G4P.SCROLLBARS_NONE);
  timerField.setOpaque(true);
  timerField.addEventHandler(this, "timerField_change1");
  label1 = new GLabel(controls_window, 369, 199, 80, 20);
  label1.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  label1.setText("TIMER");
  label1.setOpaque(false);
  amplitude = new GButton(controls_window, 79, 255, 80, 30);
  amplitude.setText("Amplitude");
  amplitude.addEventHandler(this, "amplitude_click");
  pitch = new GButton(controls_window, 165, 255, 80, 30);
  pitch.setText("Pitch");
  pitch.addEventHandler(this, "pitch_click");
  label2 = new GLabel(controls_window, -1, 29, 80, 20);
  label2.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  label2.setText("Threshold");
  label2.setOpaque(false);
  liveFeedWindow = GWindow.getWindow(this, "Live Feed", 0, 0, 320, 240, JAVA2D);
  liveFeedWindow.noLoop();
  liveFeedWindow.setActionOnClose(G4P.KEEP_OPEN);
  liveFeedWindow.addDrawHandler(this, "live_feed_draw");
  controls_window.loop();
  liveFeedWindow.loop();
}

// Variable declarations 
// autogenerated do not edit
GWindow controls_window;
GSlider threshold; 
GButton scan; 
GButton calibrate1; 
GButton calibrate2; 
GButton calibrate3; 
GButton stop; 
GButton finalizeCalibration; 
GButton automatic; 
GButton manual; 
GTextField timerField; 
GLabel label1; 
GButton amplitude; 
GButton pitch; 
GLabel label2; 
GWindow liveFeedWindow;
