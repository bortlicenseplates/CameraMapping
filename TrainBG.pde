BackgroundTraining BGT; 

class BackgroundTraining {
  int bgHue;
  int bgSat;
  int bgBri;
  int brightnessThreshold;
  int hueThreshold;
  int saturationThreshold;
  boolean displayUI,checkBG;
  BackgroundTraining(int bt, int st, int ht) {
    brightnessThreshold = bt;
    saturationThreshold = st;
    hueThreshold = ht;
  }

  void setBGCol(int x, int y, int[]pixelList, int w, int h) {
    if (w*h == pixelList.length && x > 0 && x < w && y > 0 && y < h) {
      bgHue = (int)hue(pixelList[x+(y*w)]);
      bgSat = (int)saturation(pixelList[x+(y*w)]);
      bgBri = (int)brightness(pixelList[x+(y*w)]);
    }
  }

  boolean isNotBG(int pixel) {
    if ((brightness(pixel) > bgBri+brightnessThreshold || brightness(pixel) < bgBri-brightnessThreshold) ||
      (hue(pixel) > bgHue+hueThreshold || hue(pixel) < bgHue-hueThreshold)||
      (saturation(pixel) > bgSat+saturationThreshold || saturation(pixel) < bgSat-saturationThreshold)) {
        println("Working");
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
      text("MATCH : " + !isNotBG(cpix), x+20, y+(lHeight*6));
      
    }
  }
  void checkIfGood(int pixel){
    pushStyle();
    noFill();
    colorMode(RGB);
    stroke(255);
    if(isNotBG(pixel)){
      stroke(0,0,255);
      //println("YES");
    } else if (!isNotBG(pixel)){
      stroke(255,0,0);
      //println("NO");
    }
    rect(mouseX-10,mouseY-10,20,20);
    popStyle();
  }
}