void mouseReleased()
{
  if (!keyPressed){
    println("CLICKED TO CREATE TRACKER");
    blobTracker.createBlob(mouseX, mouseY);
  }
  else{
    println("CLICKED TO DETECT BACKGROUND");
    bgManager.createColour(mouseX,mouseY);
  }
}

boolean showPositivepixels;
boolean showHistogram;
boolean showInfo;
boolean showBGCols;

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
      
    default:
      break;
  }
}