void settings()
{
  
  size(1280,720,P2D);
  PJOGL.profile = 1;
  
}
void setup()
{
  
  frameRate(120);
  
  syphonClient = new SyphonClient(this, "VDMX5");
  syphonManager = new SyphonManager();
  
  blobTracker = new BlobTracker();
  
}
void draw()
{
  
  background(0);
  colorMode(HSB);
  
  //update the Syphon client & update rawPixels[] array
  syphonManager.getInputStream();
  //show the input stream
  syphonManager.displayInputStream();
  
  //update trackers
  blobTracker.updateTrackers();
  //delete the oldest tracker if there's more than 3
  blobTracker.limitTrackerCount(3);
  
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