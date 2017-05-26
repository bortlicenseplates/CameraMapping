void mouseReleased()
{
  
  println("CLICKED TO CREATE TRACKER");
  blobTracker.createBlob(mouseX,mouseY);
  
}

boolean showPositivepixels;
boolean showHistogram;
boolean showInfo;

void keyReleased()
{
  
  switch(key)
  {
    
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
  