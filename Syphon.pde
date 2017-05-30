import codeanticode.syphon.*;
SyphonServer syphonServer;
SyphonClient syphonClient;
PImage inputStream;
PGraphics outputStream;
SyphonManager syphonManager;
int rawPixels[];

int inputWidth;
int inputHeight;


int outputWidth = int(1280*0.5);
int outputHeight = int(720*0.5);

class SyphonManager
{
  
  SyphonManager(PApplet p)
  {
    inputStream = new PImage();

    syphonClient = new SyphonClient(p);
    syphonServer = new SyphonServer(p,"Processing Mapped");
    outputStream = createGraphics(outputWidth,outputHeight,P2D);
  }
  void displayOutputStream(int outputX, int outputY){
    image(outputStream,outputX,0);
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
    
    inputWidth = width;
    inputHeight = height;
    
  }
  void displayInputStream(int inputX, int inputY, int inputW, int inputH)
  {
    image(inputStream,inputX,inputY,inputWidth,inputHeight);
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