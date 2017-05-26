BlobTracker blobTracker;

class BlobTracker
{
  
  BlobTracker()
  {
    
  }
  void createBlob(int inputX, int inputY)
  {
    
    //create a new tracker (Xposition, yPosition, startingHue, startingBrightness)
    Tracker newTracker = new Tracker(inputX, inputY,blobTracker.getHue(mouseX,mouseY),blobTracker.getBrightness(mouseX,mouseY));
    trackers.add(newTracker);
    
  }
  void updateTrackers()
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
  int getHue(int inputX, int inputY)
  {
    
    return(int(hue(rawPixels[inputY*inputWidth+inputX])));
    
  }
  //gets the brightness at a given location (xPosition, yPosition)
  int getBrightness(int inputX, int inputY)
  {
    
    return(int(brightness(rawPixels[inputY*inputWidth+inputX])));
    
  }
  //Checks if there are any trackers
  boolean thereAreTrackers()
  {
    
    if (trackers.size() > 0)
    {
      return true;
    } else {
      return false;
    }
    
  }
  //Deletes the oldest tracker if there are more than N trackers (N)
  void limitTrackerCount(int inputCount)
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
int stuckSearchAreaSize = 70;
int stuckHalfSearch = stuckSearchAreaSize/2;

//The Hue threshold for adding pixels to a blob
int maxHueDifference = 20;
//The Brightness threshold for adding pixels to a blob
int maxBrightnessDifference = 20;
//The minimum number of conforming pixels in a blob before it goes into 'lost' mode
int minimumDensity = 50;
//Smoothing factor for the histogram based position tracking
float smoothingFactor = 0.5;


ArrayList<Tracker> trackers = new ArrayList<Tracker>();

class Tracker
{
  
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
    
  }
  void update()
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
  void trackPixels()
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
          if (i > 0 && i < inputWidth && j > 0 && j < inputHeight && abs(myHue-blobTracker.getHue(i,j)) < maxHueDifference && abs(myBrightness-blobTracker.getBrightness(i,j)) < maxBrightnessDifference)
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
          if (i > 0 && i < inputWidth && j > 0 && j < inputHeight && abs(myHue-blobTracker.getHue(i,j)) < maxHueDifference && abs(myBrightness-blobTracker.getBrightness(i,j)) < maxBrightnessDifference)
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
  void search()
  {
    
    pushStyle();
    stroke(0,255,255);
    
    int strikeCounter = 0;
    
    for (int i = xPos-stuckHalfSearch; i < xPos+stuckHalfSearch; i++)
    {
      for (int j = yPos-stuckHalfSearch; j < yPos+stuckHalfSearch; j++)
      {
        if (i > 0 && i < inputWidth && j > 0 && j < inputHeight && abs(myHue-blobTracker.getHue(i,j)) < maxHueDifference && abs(myBrightness-blobTracker.getBrightness(i,j)) < maxBrightnessDifference)
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
  void display()
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
  void displayHistogram()
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
  void analyseHistogram()
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