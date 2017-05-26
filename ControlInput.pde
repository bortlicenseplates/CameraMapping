void mouseReleased()
{

  println("CLICKED TO CREATE TRACKER");
  if (!keyPressed)
    blobTracker.createBlob(mouseX, mouseY);
  else
    blobTracker.trainBG(mouseX, mouseY);
}

boolean showPositivepixels;
boolean showHistogram;
boolean showInfo;

void keyReleased()
{

  switch(key)
  {
    case'b':
      BGT.displayUI = !BGT.displayUI;
      break;
      
    case'p':
      showPositivepixels = !showPositivepixels;
      break;
  
    case'h':
      showHistogram = !showHistogram;
      break;
  
    case'i':
      showInfo = !showInfo;
      break;
    case'B':
      BGT.checkBG = !BGT.checkBG;
      break;
    default:
      break;
  }
}