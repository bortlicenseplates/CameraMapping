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
  
  void createColour(int inputX, int inputY) {
    for(int i = 0; i < sampleSize; i+=sampleSkip){
      for(int j = 0; j < sampleSize; j+=sampleSkip){
        int x = (inputX - halfSize) + i;
        int y = (inputY - halfSize) + j;
        backgroundList.add( new BackgroundTraining( brightnessThreshold, hueThreshold, saturationThreshold ) );
        backgroundList.get( backgroundList.size()-1 ).setBGCol(x, y, rawPixels, inputStream.width, inputStream.height);
      }
    }
    
  }
  
  
  void showCols(){
    
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
  
  boolean isBGColour(int pixel){
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
  color bgCol;
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

  void setBGCol(int x, int y, int[]pixelList, int w, int h) {
    if (w*h == pixelList.length && x > 0 && x < w && y > 0 && y < h) {
      bgCol = pixelList[x+(y*w)];
      bgHue = (int)hue(pixelList[x+(y*w)]);
      bgSat = (int)saturation(pixelList[x+(y*w)]);
      bgBri = (int)brightness(pixelList[x+(y*w)]);
    }
  }

  boolean isBGcol(int pixel) {
    if ((brightness(pixel) < bgBri+brightnessThreshold && brightness(pixel) > bgBri-brightnessThreshold) &&
      (hue(pixel) < bgHue+hueThreshold && hue(pixel) > bgHue-hueThreshold)&&
      (saturation(pixel) < bgSat+saturationThreshold && saturation(pixel) > bgSat-saturationThreshold)) {
      return true;
    }
    return false;
  }

  void displayBGInfo(int x, int y, int lHeight) {
    if (displayUI) {
      textMode(LEFT);
      int cpix = rawPixels[mouseX+(inputStream.width*mouseY)];
      text("BG HUE: " + bgHue + "\nHUE:" + hue(cpix), x+20, y);
      text("BG SATURATION: " + bgSat + "\nSATURATION:" + saturation(cpix), x+20, y+lHeight*2);
      text("BG BRIGHTNESS: " + bgBri + "\nBRIGHTNESS:" + brightness(cpix), x+20, y+(lHeight*4));
      text("MATCH : " + isBGcol(cpix), x+20, y+(lHeight*6));
      
    }
  }
  void checkIfGood(int pixel){
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