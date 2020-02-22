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
} //_CODE_:controls_window:756554:

public void threshold_change(GSlider source, GEvent event) { //_CODE_:threshold:411244:
  println("threshold - GSlider >> GEvent." + event + " @ " + millis());
  thresholdVal = source.getValueI();
  println("threshold is: " + threshold);
} //_CODE_:threshold:411244:

public void power_event(GButton source, GEvent event) { //_CODE_:power:596391:
  println("power - GButton >> GEvent." + event + " @ " + millis());
  redraw();
} //_CODE_:power:596391:

public void calibrate1_click1(GButton source, GEvent event) { //_CODE_:calibrate1:837833:
  println("calibrate1 - GButton >> GEvent." + event + " @ " + millis());
  calibrate = 1;
} //_CODE_:calibrate1:837833:

public void calibrate2_click1(GButton source, GEvent event) { //_CODE_:calibrate2:893355:
  println("calibrate2 - GButton >> GEvent." + event + " @ " + millis());
  calibrate = 2;
} //_CODE_:calibrate2:893355:

public void calibrate3_click1(GButton source, GEvent event) { //_CODE_:calibrate3:200157:
  println("calibrate3 - GButton >> GEvent." + event + " @ " + millis());
  calibrate = 3;
} //_CODE_:calibrate3:200157:

public void button1_click1(GButton source, GEvent event) { //_CODE_:button1:741613:
  println("button1 - GButton >> GEvent." + event + " @ " + millis());
} //_CODE_:button1:741613:



// Create all the GUI controls. 
// autogenerated do not edit
public void createGUI(){
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setMouseOverEnabled(false);
  surface.setTitle("Gooizer");
  controls_window = GWindow.getWindow(this, "controls", 640, 480, 480, 320, JAVA2D);
  controls_window.noLoop();
  controls_window.setActionOnClose(G4P.KEEP_OPEN);
  controls_window.addDrawHandler(this, "win_draw1");
  threshold = new GSlider(controls_window, 85, 19, 300, 40, 10.0);
  threshold.setShowValue(true);
  threshold.setShowLimits(true);
  threshold.setLimits(25, 0, 255);
  threshold.setNumberFormat(G4P.INTEGER, 0);
  threshold.setOpaque(false);
  threshold.addEventHandler(this, "threshold_change");
  power = new GButton(controls_window, 82, 86, 80, 30);
  power.setText("Scan");
  power.addEventHandler(this, "power_event");
  calibrate1 = new GButton(controls_window, 82, 124, 80, 30);
  calibrate1.setText("Calibrate Color 1");
  calibrate1.addEventHandler(this, "calibrate1_click1");
  calibrate2 = new GButton(controls_window, 168, 124, 80, 30);
  calibrate2.setText("Calibrate Color 2");
  calibrate2.addEventHandler(this, "calibrate2_click1");
  calibrate3 = new GButton(controls_window, 256, 125, 80, 30);
  calibrate3.setText("Calibrate Color 3");
  calibrate3.addEventHandler(this, "calibrate3_click1");
  button1 = new GButton(controls_window, 168, 86, 80, 30);
  button1.setText("Stop");
  button1.addEventHandler(this, "button1_click1");
  controls_window.loop();
}

// Variable declarations 
// autogenerated do not edit
GWindow controls_window;
GSlider threshold; 
GButton power; 
GButton calibrate1; 
GButton calibrate2; 
GButton calibrate3; 
GButton button1; 
