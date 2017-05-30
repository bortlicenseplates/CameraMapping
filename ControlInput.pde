
import controlP5.*;
ControlP5 cp5;

void createControls(){
  cp5 = new ControlP5(this);
  cp5.addSlider("xWeightX")
    .setPosition(20,20)
    .setSize(150,10)
    .setRange(0.5,1.5)
    .setValue(1);
    ;

  cp5.addSlider("yWeightX")
    .setPosition(20,40)
    .setSize(150,10)
    .setRange(0.5,1.5)
    .setValue(1)
    ;


  cp5.addSlider("xWeightY")
    .setPosition(200,20)
    .setSize(150,10)
    .setRange(0.5,1.5)
    .setValue(1)
    ;

  cp5.addSlider("yWeightY")
    .setPosition(200,40)
    .setSize(150,10)
    .setRange(0.5,1.5)
    .setValue(1)
    ;

  cp5.addSlider("lenseAngle")
    .setPosition(20,60)
    .setSize(150,10)
    .setRange(-20,20)
    .setValue(0)
    ;
}

void mouseReleased()
{
  if(trainTrackers && !keyPressed){
    println(startpoints.size());
    println(endpoints.size());
    singleClick = true;
    println(singleClick);

  }
  // if (!keyPressed){
  //   println("CLICKED TO CREATE TRACKER");
  //   blobTracker.createBlob(mouseX, mouseY);
  // }
  // else if (keyPressed && key == 'z'){
  //   println("CLICKED TO DETECT BACKGROUND");
  //   bgManager.createColour(mouseX,mouseY);
  // }
}

boolean showPositivepixels;
boolean showHistogram;
boolean showInfo;
boolean showBGCols;
boolean trainTrackers;
boolean singleClick;

void keyReleased()
{

  switch(key)
  {
    
    case'b':
      showBGCols = !showBGCols;
    
    case'p':
      showPositivepixels = !showPositivepixels;
      break;
  
    case'h':
      showHistogram = !showHistogram;
      break;
  
    case'i':
      showInfo = !showInfo;
      break;

    case'1':
      println("TRAINING TRACKERS");
      startpoints.clear();
      endpoints.clear();
      trainTrackers = true;
      break;

    case'2':
      println("FINISHED TRAINING");
      trainTrackers = false;
      break;
      
    default:
      break;
  }
}