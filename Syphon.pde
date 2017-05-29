import codeanticode.syphon.*;
SyphonServer syphonServer;
SyphonClient syphonClient;
PImage inputStream;
PGraphics outputStream;
SyphonManager syphonManager;
int rawPixels[];

int inputWidth;
int inputHeight;


int outputWidth = 1280;
int outputHeight = 720;

class SyphonManager
{
  
  SyphonManager(PApplet p)
  {
    inputStream = new PImage();

    syphonClient = new SyphonClient(p);
    syphonServer = new SyphonServer(p,"Processing Mapped");
    outputStream = createGraphics(outputWidth,outputHeight,P2D);
  }
  void displayOutputStream(){
    image(outputStream,inputStream.width,0);
  }
  void sendStream(){
    syphonServer.sendImage(outputStream);
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
    image(inputStream,0,0,width,(width/16)*9);
  }
}