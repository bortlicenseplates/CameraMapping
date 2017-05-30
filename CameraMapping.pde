void settings()
{
  
  size(640,460,P2D);
  PJOGL.profile = 1;
  
}
void setup()
{
  
  frameRate(120);
  
  syphonManager = new SyphonManager(this);
  
  blobTracker = new BlobTracker();
  bgManager = new BackgroundManager();
  mapCamera = new MapCamera();
  createControls();
  testSmoothBoxSetup();
}
void draw()
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
void showInfo()
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
void showHistogram1()
{
  
  if (blobTracker.thereAreTrackers())
  {
    Tracker tracker1 = trackers.get(0);
    tracker1.displayHistogram();
  }
  
}