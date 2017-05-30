import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import codeanticode.syphon.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class CameraMapping extends PApplet {

public void settings()
{
  
  size(640,460,P2D);
  PJOGL.profile = 1;
  
}
public void setup()
{
  
  frameRate(120);
  
  syphonManager = new SyphonManager(this);
  
  blobTracker = new BlobTracker();
  bgManager = new BackgroundManager();
  mapCamera = new MapCamera();
  createControls();
  testSmoothBoxSetup();
}
public void draw()
{
  
  background(0);
  colorMode(RGB);
  
  //update the Syphon client & update rawPixels[] array
  syphonManager.getInputStream();
  //show the input stream
  syphonManager.displayInputStream(0,0,width,height);
  // syphonManager.displayOutputStream(width/2,0);
  syphonManager.sendStream();
  
  //update trackers
  // blobTracker.updateTrackers();
  //delete the oldest tracker if there's more than 3
  // blobTracker.limitTrackerCount(1);
  mapCamera.addPoints(mouseX, mouseY);
  mapCamera.test(mouseX, mouseY);
  mapCamera.testthree(mouseX, mouseY);
  
  //show framerate, etc
  if (showInfo)
  {
    showInfo();
  }
  
  //hit 'h' to display the first trackers histogram
  if (showHistogram)
  {
    showHistogram1();
  }
  if(showBGCols){
    bgManager.showCols();
  }
  testSmoothBox();
  
}
public void showInfo()
{
  
  pushStyle();
  noStroke();
  fill(255);
  text("FRAME RATE: " + frameRate,20,20);
  text("RED AT MOUSE: " + red(rawPixels[mouseY*inputStream.width+mouseX]),20,40);
  text("GREEN AT MOUSE: " + green(rawPixels[mouseY*inputStream.width+mouseX]),20,60);
  text("BLUE AT MOUSE: " + blue(rawPixels[mouseY*inputStream.width+mouseX]),20,80);
  text("HUE AT MOUSE: " + hue(rawPixels[mouseY*inputStream.width+mouseX]),20,100);
  text("SATURATION AT MOUSE: " + saturation(rawPixels[mouseY*inputStream.width+mouseX]),20,120);
  text("BRIGHTNESS AT MOUSE: " + brightness(rawPixels[mouseY*inputStream.width+mouseX]),20,140);
  popStyle();
  
}
public void showHistogram1()
{
  
  if (blobTracker.thereAreTrackers())
  {
    Tracker tracker1 = trackers.get(0);
    tracker1.displayHistogram();
  }
  
}
BackgroundManager bgManager;

class BackgroundManager{
  int sampleSize = 20;
  int sampleSkip = 5;
  int totalSamples = (int)((sampleSize*sampleSize)/sampleSkip);
  int halfSize = (int)(sampleSize/2);
  int brightnessThreshold = 20;
  int hueThreshold = 20;
  int saturationThreshold = 10;
  ArrayList<BackgroundTraining> backgroundList;
  BackgroundManager(){
    backgroundList = new ArrayList<BackgroundTraining>();
  }
  
  public void createColour(int inputX, int inputY) {
    for(int i = 0; i < sampleSize; i+=sampleSkip){
      for(int j = 0; j < sampleSize; j+=sampleSkip){
        int x = (inputX - halfSize) + i;
        int y = (inputY - halfSize) + j;
        backgroundList.add( new BackgroundTraining( brightnessThreshold, hueThreshold, saturationThreshold ) );
        backgroundList.get( backgroundList.size()-1 ).setBGCol(x, y, rawPixels, inputStream.width, inputStream.height);
      }
    }
    
  }
  
  
  public void showCols(){
    
    boolean check = false;
    if(backgroundList.size() > 0){
      for (int i = 0; i < backgroundList.size(); i++){
        BackgroundTraining bgt = backgroundList.get(i);
        if(bgt.isBGcol(rawPixels[mouseX+(mouseY*inputStream.width)])){
          check = true;
        }
        fill(bgt.bgCol);
        rect(i*10,0,10,10);
      }
    }
    pushStyle();
    noFill();
    if (check){
      stroke(255,0,0);
    }else{
      stroke(0,255,0);
    }
    rect(mouseX-halfSize,mouseY-halfSize,sampleSize,sampleSize);
    popStyle();
  }
  
  public boolean isBGColour(int pixel){
    if(backgroundList.size() > 0){
      for (BackgroundTraining bgt : backgroundList){
        if(bgt.isBGcol(pixel)){
          return true;
        }
      }
    }
    return false;
  }
}

class BackgroundTraining {
  int bgCol;
  int bgHue;
  int bgSat;
  int bgBri;
  int brightnessThreshold;
  int hueThreshold;
  int saturationThreshold;
  boolean displayUI,checkBG;
  BackgroundTraining(int bt, int ht, int st) {
    brightnessThreshold = bt;
    saturationThreshold = st;
    hueThreshold = ht;
  }

  public void setBGCol(int x, int y, int[]pixelList, int w, int h) {
    if (w*h == pixelList.length && x > 0 && x < w && y > 0 && y < h) {
      bgCol = pixelList[x+(y*w)];
      bgHue = (int)hue(pixelList[x+(y*w)]);
      bgSat = (int)saturation(pixelList[x+(y*w)]);
      bgBri = (int)brightness(pixelList[x+(y*w)]);
    }
  }

  public boolean isBGcol(int pixel) {
    if ((brightness(pixel) < bgBri+brightnessThreshold && brightness(pixel) > bgBri-brightnessThreshold) &&
      (hue(pixel) < bgHue+hueThreshold && hue(pixel) > bgHue-hueThreshold)&&
      (saturation(pixel) < bgSat+saturationThreshold && saturation(pixel) > bgSat-saturationThreshold)) {
      return true;
    }
    return false;
  }

  public void displayBGInfo(int x, int y, int lHeight) {
    if (displayUI) {
      textMode(LEFT);
      int cpix = rawPixels[mouseX+(inputStream.width*mouseY)];
      text("BG HUE: " + bgHue + "\nHUE:" + hue(cpix), x+20, y);
      text("BG SATURATION: " + bgSat + "\nSATURATION:" + saturation(cpix), x+20, y+lHeight*2);
      text("BG BRIGHTNESS: " + bgBri + "\nBRIGHTNESS:" + brightness(cpix), x+20, y+(lHeight*4));
      text("MATCH : " + isBGcol(cpix), x+20, y+(lHeight*6));
      
    }
  }
  public void checkIfGood(int pixel){
    pushStyle();
    noFill();
    colorMode(RGB);
    stroke(255);
    if(isBGcol(pixel)){
      stroke(255,0,0);
      //println("YES");
    } else {
      stroke(0,255,0);
      //println("NO");
    }
    
  }
}
BlobTracker blobTracker;

class BlobTracker
{
  
  BlobTracker()
  {
    
  }
  public void createBlob(int inputX, int inputY)
  {
    
    //create a new tracker (Xposition, yPosition, startingHue, startingBrightness)
    if(!bgManager.isBGColour(rawPixels[inputX+(inputY*inputWidth)])){
      Tracker newTracker = new Tracker(inputX, inputY,blobTracker.getHue(mouseX,mouseY),blobTracker.getBrightness(mouseX,mouseY));
      trackers.add(newTracker);
    }
    
  }
  public void updateTrackers()
  {
    
    //If tracker arrayList is longer than zero
    if (thereAreTrackers())
    {
      //Update and display all trackers
      for (int i = 0; i < trackers.size(); i++)
      {
        Tracker thisTracker = trackers.get(i);
        thisTracker.update();
        thisTracker.display();
      }
    }
    
  }
  //gets the hue at a given location (xPosition, yPosition)
  public int getHue(int inputX, int inputY)
  {
    
    return(PApplet.parseInt(hue(rawPixels[inputY*inputWidth+inputX])));
    
  }
  //gets the brightness at a given location (xPosition, yPosition)
  public int getBrightness(int inputX, int inputY)
  {
    
    return(PApplet.parseInt(brightness(rawPixels[inputY*inputWidth+inputX])));
    
  }
  //Checks if there are any trackers
  public boolean thereAreTrackers()
  {
    
    if (trackers.size() > 0)
    {
      return true;
    } else {
      return false;
    }
    
  }
  //Deletes the oldest tracker if there are more than N trackers (N)
  public void limitTrackerCount(int inputCount)
  {
    
    if (trackers.size() > inputCount)
    {
      trackers.remove(0);
    }
    
  }
}




//__________//
// TRACKERS //
//__________//

//The size of the search square
int searchAreaSize = 100;
int halfSearch = searchAreaSize/2;

//The size of the search square if the tracker is lost
int stuckSearchAreaSize = (int)(searchAreaSize*1.5f);
int stuckHalfSearch = stuckSearchAreaSize/2;

//The Hue threshold for adding pixels to a blob
int maxHueDifference = 20;
//The Brightness threshold for adding pixels to a blob
int maxBrightnessDifference = 20;
//The minimum number of conforming pixels in a blob before it goes into 'lost' mode
int minimumDensity = 50;
//Smoothing factor for the histogram based position tracking
float smoothingFactor = 0.5f;


ArrayList<Tracker> trackers = new ArrayList<Tracker>();

class Tracker
{
  SmoothBox smoothBox;
  int xPos;
  int yPos;
  int leftX;
  int rightX;
  int topY;
  int bottomY;
  int myHue;
  int myBrightness;
  int myWidth;
  int myHeight;
  
  boolean stuck;
  
  int xHistogram[] = new int[searchAreaSize];
  int yHistogram[] = new int[searchAreaSize];
  int highestXindex;
  int highestYindex;
  
  float smoothedXindex;
  float smoothedYindex;
  
  Tracker(int inputX, int inputY, int inputHue, int inputBrightness)
  {
    
    xPos = inputX;
    leftX = inputX;
    rightX = inputX;
    yPos = inputY;
    topY = inputY;
    bottomY = inputY;
    myHue = inputHue;
    myBrightness = inputBrightness;
    
    println("NEW TRACKER CREATED AT: " + xPos + "," + yPos);
    println("TRACKER HUE: " + inputHue);
    println("TRACKER BRIGHTNESS: " + inputBrightness);
    smoothBox = new SmoothBox();
    
  }
  public void update()
  {
    
    // if there aren't enough conforming pixels in this tracker, go into search mode
    if (stuck)
    {
      search();
    } else {
      trackPixels();
    }
    
    //Find the local max in the X & Y histograms 
    analyseHistogram();
    
  }
  public void trackPixels()
  {
    
    //Clear the histograms
    for (int i = 0; i < searchAreaSize; i++)
    {
      xHistogram[i] = 0;
      yHistogram[i] = 0;
    }
    
    //Clear the strike counter (number of conforming pixels in this blob)
    int strikeCounter = 0;
    
    topY = inputHeight;
    bottomY = 0;
    leftX = inputWidth;
    rightX = 0;
    
    leftX = xPos-halfSearch;
    rightX = xPos+halfSearch;
    topY = yPos-halfSearch;
    bottomY = yPos+halfSearch;
    
    //Highlight the conforming pixels as we go if the switch is true (hit [p] to switch on or off)
    if (showPositivepixels)
    {
      
      pushStyle();
      stroke(255);
    
      //for my search area:
      for (int i = xPos-halfSearch; i < xPos+halfSearch; i++)
      {
        for (int j = yPos-halfSearch; j < yPos+halfSearch; j++)
        {
          //If we're within the pixel array size && the hue difference is within the threshold && the brightness difference is within the threshold:
          if (i > 0 && i < inputWidth && j > 0 && j < inputHeight && 
            abs(myHue-blobTracker.getHue(i,j)) < maxHueDifference && 
            abs(myBrightness-blobTracker.getBrightness(i,j)) < maxBrightnessDifference && 
            !bgManager.isBGColour(rawPixels[i+(j*inputStream.width)]))
          {
            //Draw the highlight point
            point(i,j);
            //Add to the conforming pixel count
            strikeCounter++;
            //Add X & Y positions to the histograms
            xHistogram[i-leftX]++;
            yHistogram[j-topY]++;
          }
        }
      }
    
      popStyle();
       
      //Else do the same thing, but without highlighting pixels (saves us running two simultaneous for loops
      } else {
    
      for (int i = xPos-halfSearch; i < xPos+halfSearch; i++)
      {
        for (int j = yPos-halfSearch; j < yPos+halfSearch; j++)
        {
          if (i > 0 && i < inputWidth && j > 0 && j < inputHeight && 
            abs(myHue-blobTracker.getHue(i,j)) < maxHueDifference && 
            abs(myBrightness-blobTracker.getBrightness(i,j)) < maxBrightnessDifference &&
            !bgManager.isBGColour(rawPixels[i+(j*inputStream.width)]))
          {
            strikeCounter++;
            xHistogram[i-leftX]++;
            yHistogram[j-topY]++;
          }
        }
      }
    
    }
    
    //Think this a leftover quick fix maybe
    myWidth = searchAreaSize;
    myHeight = searchAreaSize;
    
    //Smooth acceleration towards the target X & Y, as defined by the local Max in the two histograms (highestXindex and highestYindex are those local max numbers)
    xPos += (highestXindex-(xPos-leftX))*smoothingFactor;
    yPos += (highestYindex-(yPos-topY))*smoothingFactor;
    
    //If not enough conforming pixels were found, go into search mode
    if (strikeCounter < minimumDensity)
    {
      stuck = true;
    } else {
      stuck = false;
    }
    
  }
  //Search mode, basically works the same as trackPixels mode but doesn't update position and has a larger search area
  //The point being that it'll flick the 'stuck' switch to false once it's found its target, and hop back in to trackPixels mode
  public void search()
  {
    
    pushStyle();
    stroke(0,255,255);
    
    int strikeCounter = 0;
    
    for (int i = xPos-stuckHalfSearch; i < xPos+stuckHalfSearch; i++)
    {
      for (int j = yPos-stuckHalfSearch; j < yPos+stuckHalfSearch; j++)
      {
        if (i > 0 && i < inputWidth && j > 0 && j < inputHeight && 
          abs(myHue-blobTracker.getHue(i,j)) < maxHueDifference && 
          abs(myBrightness-blobTracker.getBrightness(i,j)) < maxBrightnessDifference &&
          !bgManager.isBGColour(rawPixels[i+(j*inputStream.width)]))
        {
          point(i,j);
          strikeCounter++;
        }
      }
    }
    popStyle();
    
    if (strikeCounter < minimumDensity)
    {
      stuck = true;
    } else {
      stuck = false;
    }
    
  }
  //Draw a white tracker if not stuck, a red one if stuck, indicating the size of the search areas
  public void display()
  {
    
    if (stuck)
    {
      pushStyle();
      noFill();
      stroke(0,255,255);
      rect(leftX,topY,stuckSearchAreaSize,stuckSearchAreaSize);
      popStyle();
    } else {
      pushStyle();
      noFill();
      stroke(255);
      rect(leftX,topY,searchAreaSize,searchAreaSize);
      popStyle();
    }
    
  }
  //Draw the X and Y histogram
  public void displayHistogram()
  {
    
    pushStyle();
    noStroke();
    fill(0);
    rect(0,height-searchAreaSize,searchAreaSize*2,searchAreaSize);
    stroke(0,255,255);
    for(int i = 0; i < searchAreaSize; i++)
    {
      line(i,height,i,height-xHistogram[i]);
    }
    stroke(100,255,255);
    for(int i = 0; i < searchAreaSize; i++)
    {
      line(searchAreaSize+i,height,searchAreaSize+i,height-yHistogram[i]);
    }
    stroke(255);
    line(highestXindex,height,highestXindex,height-searchAreaSize);
    line(highestYindex+searchAreaSize,height,highestYindex+searchAreaSize,height-searchAreaSize);
    popStyle();
    
  }
  //Find the local max in both X & Y histograms
  public void analyseHistogram()
  {
    
    //Set local max to zero so it'll always return a result
    int highestX = 0;
    int highestY = 0;
    
    //For the histogram size:
    for (int i = 0; i < searchAreaSize; i++)
    {
      //If any index returns a higher value than the previous highest value:
      if (xHistogram[i] > highestX)
      {
        //update the highest value (not actually used but maybe useful in the future)
        highestX = xHistogram[i];
        //update the index of the highest value (used for determining the target location)
        highestXindex = i;
      }
      //Do the same for the Y histogram
      if (yHistogram[i] > highestY)
      {
        highestY = yHistogram[i];
        highestYindex = i;
      }
    }

  }
}


ControlP5 cp5;

public void createControls(){
  cp5 = new ControlP5(this);
  cp5.addSlider("xWeightX")
    .setPosition(20,20)
    .setSize(150,10)
    .setRange(0.5f,1.5f)
    .setValue(1);
    ;

  cp5.addSlider("yWeightX")
    .setPosition(20,40)
    .setSize(150,10)
    .setRange(0.5f,1.5f)
    .setValue(1)
    ;


  cp5.addSlider("xWeightY")
    .setPosition(200,20)
    .setSize(150,10)
    .setRange(0.5f,1.5f)
    .setValue(1)
    ;

  cp5.addSlider("yWeightY")
    .setPosition(200,40)
    .setSize(150,10)
    .setRange(0.5f,1.5f)
    .setValue(1)
    ;

  cp5.addSlider("lenseAngle")
    .setPosition(20,60)
    .setSize(150,10)
    .setRange(-20,20)
    .setValue(0)
    ;
}

public void mouseReleased()
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

public void keyReleased()
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
MapCamera mapCamera;

float realX, realY;
float realCentreX, realCentreY;
float xWeightX, yWeightX, xWeightY, yWeightY, lenseAngle;
float cameraX_theta, cameraY_theta;
float cameraX_position, cameraY_position, cameraZ_position;

float E = (float)Math.E;
float xMapExponent;
ArrayList<PVector> startpoints;
ArrayList<PVector> endpoints;
class MapCamera{
	
	
	MapCamera(){
		startpoints = new ArrayList<PVector>();
		endpoints = new ArrayList<PVector>();
		realX = 0;
		realY = 0;
		realCentreX = outputStream.width/2;
		realCentreY=outputStream.height/2;
	}

	public void setT(){
		float[] t = new float[2];
		float[] y = new float[2];
		for(int i = 0; i < 2; i++){
			t[i] = abs((startpoints.get(i).x - width/2)-(endpoints.get(i).x - width/2));
			y[i] = startpoints.get(i).x;
		}
		xMapExponent = getExponent(t[0], t[1],y[0],y[1]);
	}

	public float getExponent(float t1, float t2, float y1, float y2){
		return E*((log(y1) - log(y2))/(t1 - t2));
	}


	///IGNORE FOR NOW

	public void createStartPoint(int inputX, int inputY){
		startpoints.add(new PVector(inputX, inputY));
	}

	public void createEndPoint(int inputX, int inputY){
		endpoints.add(new PVector(inputX, inputY));
	}
	int clickCount = 0;

	public void addPoints(int xIn, int yIn){
		if(trainTrackers) {
			if(clickCount%2 == 0 && singleClick){
				createStartPoint(xIn, mouseY);
				singleClick = false;
				clickCount++;
				println(startpoints.size());
			    println(endpoints.size());
			} else if(singleClick && clickCount%2 == 1){
				createEndPoint(xIn, mouseY);
				clickCount++;
				singleClick = false;
				println(startpoints.size());
			    println(endpoints.size());
			}
		}
	}

	public void calibrate(){
		
	}

	public void mapPoint(int x, int y){
		realX = (x*xWeightX)+(y*yWeightX);
		realX *= (abs(realX - realCentreX)*lenseAngle)+(abs(realY - realCentreY)*lenseAngle);
	}

	public void testthree(int xIn, int yIn){
		if(endpoints.size()>=4 && startpoints.size() >= 4){

			// float thetaA1 = PVector.angleBetween(startpoints.get(0), startpoints.get(1));
			// float thetaB1 = PVector.angleBetween(endpoints.get(0), endpoints.get(1));
			// float thetaA2 = PVector.angleBetween(startpoints.get(2), startpoints.get(3));
			// float thetaB2 = PVector.angleBetween(endpoints.get(2), endpoints.get(3));
			// float distanceA1 = dist(startpoints.get(0).x, startpoints.get(0).y,startpoints.get(1).x, startpoints.get(1).y);
			// float distanceB1 = dist(endpoints.get(0).x, endpoints.get(0).y,endpoints.get(1).x, endpoints.get(1).y);
			// float distanceA2 = dist(startpoints.get(2).x, startpoints.get(2).y,startpoints.get(3).x, startpoints.get(3).y);
			// float distanceB2 = dist(endpoints.get(2).x, endpoints.get(2).y,endpoints.get(3).x, endpoints.get(3).y);
			// float rotation1 = thetaB1-thetaA1;
			// float rotation2 = thetaB2-thetaA2;
			float leftX = lerp(endpoints.get(0).x,endpoints.get(2).x,map(mouseY*yWeightX,startpoints.get(0).y, startpoints.get(2).y,0,1));
			float rightX = lerp(endpoints.get(1).x,endpoints.get(3).x,map(mouseY*yWeightX,startpoints.get(1).y, startpoints.get(3).y,0,1));
			realX = lerp(leftX,rightX,map(xIn*xWeightX,startpoints.get(0).x,startpoints.get(1).x,0,1));
			// float realX2 = lerp(leftX,rightX,map(xIn*xWeightX,startpoints.get(2).x,startpoints.get(3).x,0,1));
			// realX = lerp(realX1,realX2,map(mouseY,startpoints.get(0).y,startpoints.get(2).y,1,0));
			// realX = lerp(leftX,rightX,map(xIn*xWeightX,startpoints.get(0).x,startpoints.get(1).x,0,1));

			float leftY = lerp(endpoints.get(0).y,endpoints.get(1).y,map(xIn*xWeightY,startpoints.get(0).x, startpoints.get(1).x,0,1));
			float rightY = lerp(endpoints.get(2).y,endpoints.get(3).y,map(xIn*xWeightY,startpoints.get(2).x, startpoints.get(3).x,0,1));
			realY = lerp(leftY,rightY,map(mouseY*yWeightY,startpoints.get(0).y,startpoints.get(2).y,0,1));
			// float realY2 = lerp(leftY,rightY,map(mouseY*yWeightY,startpoints.get(1).y,startpoints.get(3).y,0,1));
			// realY = lerp(realY1,realY2,map(xIn,startpoints.get(0).x,startpoints.get(1).x,1,0));
			


			if(keyPressed){
						println("startX: "+xIn);
						println("realX: "+realX);
			
						println("startY: "+mouseY);
						println("realY: "+realY);
					}
		}
		// println(xMapExponent);
		// realX = (xIn*xMapExponent) + outputStream.width/2;

	}

	// void testtwo(){
	// 	if(endpoints.size()>=4 && startpoints.size() >= 4){
	// 		// setT();
	// 		float xdif = curvePoint(abs(startpoints.get(0).x - endpoints.get(0).x),abs(startpoints.get(1).x - endpoints.get(1).x),
	// 								abs(startpoints.get(2).x - endpoints.get(2).x), abs(startpoints.get(3).x - endpoints.get(3).x),
	// 								map(xIn,0,width,0,1));

	// 		float ydif = curvePoint(startpoints.get(0).y - endpoints.get(0).y,startpoints.get(1).y - endpoints.get(1).y,
	// 								startpoints.get(2).y - endpoints.get(2).y, startpoints.get(3).y - endpoints.get(3).y,
	// 								map(mouseY,0,height,1,0));
	// 		println(xdif);
	// 		realX = xdif;
	// 		realY = ydif;
	// 	}
		// println(xMapExponent);
		// realX = (xIn*xMapExponent) + outputStream.width/2;

	// }

	public void test(int xIn, int yIn){
		noFill();
		stroke(255);
		// rect(100,100,500,500);
		// rect(120,120,480,480);
		// mapPoint(xIn, yIn);
		// println(realX);
		outputStream.beginDraw();
		outputStream.pushStyle();
		outputStream.background(0);
		pushStyle();
		if(trainTrackers){
			noFill();
			stroke(255);
			rect(xIn-10,yIn-10,20,20);
			outputStream.stroke(255);
			outputStream.noFill();
			outputStream.rect(xIn-10,yIn-10,20,20);
		} else {
			noFill();
			stroke(0,100,255);
			rect(xIn-10,yIn-10,20,20);
			outputStream.stroke(0,255,0);
			outputStream.noFill();
			outputStream.rect(realX-5,realY-5+lenseAngle,10,10);

		}
		
		popStyle();
		outputStream.fill(255);
		// outputStream.rect(realCentreX-10, realCentreY-10, 20, 20);
		outputStream.popStyle();
		outputStream.endDraw();
	}

}

SyphonServer syphonServer;
SyphonClient syphonClient;
PImage inputStream;
PGraphics outputStream;
SyphonManager syphonManager;
int rawPixels[];

int inputWidth;
int inputHeight;


int outputWidth = PApplet.parseInt(1280*0.5f);
int outputHeight = PApplet.parseInt(720*0.5f);

class SyphonManager
{
  
  SyphonManager(PApplet p)
  {
    inputStream = new PImage();

    syphonClient = new SyphonClient(p);
    syphonServer = new SyphonServer(p,"Processing Mapped");
    outputStream = createGraphics(outputWidth,outputHeight,P2D);
  }
  public void displayOutputStream(int outputX, int outputY){
    image(outputStream,outputX,0);
  }
  public void sendStream(){
    syphonServer.sendImage(outputStream);
  }

  public void getInputStream()
  {
    
    if (syphonClient.newFrame())
    {
      inputStream = syphonClient.getImage(inputStream);
    }
    
    inputStream.loadPixels();
    rawPixels = inputStream.pixels;
    
    inputWidth = width;
    inputHeight = height;
    
  }
  public void displayInputStream(int inputX, int inputY, int inputW, int inputH)
  {
    image(inputStream,inputX,inputY,inputWidth,inputHeight);
  }
  public void displayInputStream(int inputX, int inputY)
  {
    image(inputStream,inputX,inputY);
  }
  public void displayInputStream()
  {
    image(inputStream,0,0,width,(width/16)*9);
  }
}
// smoothBox::
// 	float xyIn, float xyOut
// 	float x, y, width, height;
// 	float smoothingFactor << 0->1 >>

// 	PVector boundingBox(int xIn, int yIn){
// 		if(xIn && yIn -> !inside box){
// 			xOut = lerp(previousX,xIn,smoothingFactor)
// 		}
// 		previousX, previousY = xOut, yOut
// 	}

class SmoothBox{
	float smoothedX, smoothedY;
	float previousX;
	float previousY;
	float edgeX, edgeY;
	float smoothingFactorX, smoothingFactorY;
	float timer;
	SmoothBox(){

	}

	public float smoothingBoxX(float x, float boxSize, float smoothX){
		float halfBox = boxSize/2;
		float checker = abs(previousX-halfBox);
		if((-checker<x-halfBox || checker > x+ halfBox) && abs(previousX-x) > halfBox){
			// println(abs(x-previousX)>mouseX-halfBox); 
			smoothedX = smoothedX(x,smoothX);
			previousX = smoothedX;
			edgeX = smoothedX;
			return smoothedX;
		} else {
			if((edgeX-x) > 5){
				previousX = lerp(previousX, edgeX-halfBox, smoothX/100);
			} else if((edgeX-x) < -5){
				previousX = lerp(previousX, edgeX+halfBox, smoothX/100);
			}
		}
		
		return previousX;
	}

	public float smoothingBoxY(float y, float boxSize, float smoothY){
		float halfBox = boxSize/2;
		float checker = abs(previousY-halfBox);
		if((-checker<y-halfBox || checker > y+ halfBox) && abs(previousY-y) > halfBox){
			// println(abs(x-previousX)>mouseX-halfBox); 
			smoothedY = smoothedY(y,smoothY);
			previousY = smoothedY;
			edgeY = smoothedY;
			return smoothedY;
		} else {
			if((edgeY-y) > 5){
				previousY = lerp(previousY, edgeY-halfBox, smoothY/100);
			} else if((edgeY-y) < -5){
				previousY = lerp(previousY, edgeY+halfBox, smoothY/100);
			}
		}
		
		return previousY;
	}

	//enter x position, enter percent of difference between x and prevoius x to move by
	public float smoothedX(float x, float smoothingFactor){
		smoothingFactor = constrain(smoothingFactor/100, 0, 1);
		return lerp(previousX, x, smoothingFactor);
	}

	public float smoothedY(float y, float smoothingFactor){
		smoothingFactor = constrain(smoothingFactor/100, 0, 1);
		return lerp(previousY, y, smoothingFactor);
	}


}
SmoothBox smoothBox;
public void testSmoothBoxSetup(){
	smoothBox = new SmoothBox();
}

public void testSmoothBox(){
	pushMatrix();
	pushStyle();
	float xpos = smoothBox.smoothingBoxX(mouseX,100,2);
	float ypos = smoothBox.smoothingBoxY(mouseY,100,2);
	rectMode(CENTER);
	rect(xpos,ypos,100,100);
	popStyle();
	popMatrix();
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "CameraMapping" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
