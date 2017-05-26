import codeanticode.syphon.*;
SyphonClient syphonClient;
PImage inputStream;

SyphonManager syphonManager;
int rawPixels[];

int inputWidth;
int inputHeight;

class SyphonManager
{
  
  SyphonManager()
  {
    inputStream = new PImage();
  }
  void getInputStream()
  {
    
    if (syphonClient.newFrame())
    {
      inputStream = syphonClient.getImage(inputStream);
    }
    
    inputStream.loadPixels();
    rawPixels = inputStream.pixels;
    
    inputWidth = inputStream.width;
    inputHeight = inputStream.height;
    
  }
  void displayInputStream(int inputX, int inputY)
  {
    
    image(inputStream,inputX,inputY);
    
  }
  void displayInputStream()
  {
    
    image(inputStream,0,0);
    
  }
}