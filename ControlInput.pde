
import controlP5.*;
ControlP5 cp5;

void createControls(){
  cp5 = new ControlP5(this);
  cp5.addSlider("xWeight")
    .setPosition(20,20)
    .setSize(150,10)
    .setRange(-0.5,0.5)
    ;

  cp5.addSlider("yWeight")
    .setPosition(20,30)
    .setSize(150,10)
    .setRange(-0.5,0.5)
    ;

  cp5.addSlider("lenseAngle")
    .setPosition(20,40)
    .setSize(150,10)
    .setRange(0,0.5)
    ;
}

void mouseReleased()
{
  if(trainTrackers && !keyPressed){
    println(mapCamera.startpoints.size());
    println(mapCamera.endpoints.size());
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