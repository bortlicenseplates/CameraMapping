MapCamera mapCamera;

float realX, realY;
float realCentreX, realCentreY;
float xWeight, yWeight, lenseAngle;
float cameraX_theta, cameraY_theta;
float cameraX_position, cameraY_position, cameraZ_position;

class MapCamera{
	ArrayList<PVector> startpoints;
	ArrayList<PVector> endpoints;
	
	MapCamera(){
		startpoints = new ArrayList<PVector>();
		endpoints = new ArrayList<PVector>();
		realX = 0;
		realY = 0;
		realCentreX = outputStream.width/2;
		realCentreY=outputStream.height/2;
	}

	void createStartPoint(int inputX, int inputY){
		startpoints.add(new PVector(inputX, inputY));
	}

	void createEndPoint(int inputX, int inputY){
		endpoints.add(new PVector(inputX, inputY));
	}
	int clickCount = 0;

	void addPoints(){
		if(trainTrackers) {
			if(clickCount%2 == 0 && singleClick){
				createStartPoint(mouseX, mouseY);
				singleClick = false;
				clickCount++;
			} else if(singleClick && clickCount%2 == 1){
				createEndPoint(mouseX, mouseY);
				clickCount++;
				singleClick = false;
			} 
		}
	}

	void calibrate(){
		FloatList xPositions = new FloatList();
		FloatList yPositions = new FloatList();
		for(int i = 0; i < endpoints.size(); i++){

			// xPositions.append();
		}
	}

	void mapPoint(int x, int y){
		realX = (x*xWeight)+(y*yWeight);
		realX *= (abs(realX - realCentreX)*lenseAngle)+(abs(realY - realCentreY)*lenseAngle);
	}

	void test(){
		mapPoint(mouseX, mouseY);
		println(xWeight);
		outputStream.beginDraw();
		outputStream.pushStyle();
		outputStream.background(0);
		pushStyle();
		if(trainTrackers){
			noFill();
			stroke(255);
			rect(mouseX-10,mouseY-10,20,20);
			outputStream.stroke(255);
			outputStream.noFill();
			outputStream.rect(mouseX-10,mouseY-10,20,20);
		} else {
			noFill();
			stroke(0,100,255);
			rect(mouseX-10,mouseY-10,20,20);
			outputStream.stroke(0,100,255);
			outputStream.noFill();
			outputStream.rect(realX-10,realY-10,20,20);
		}
		
		popStyle();
		outputStream.fill(255);
		outputStream.rect(realCentreX-10, realCentreY-10, 20, 20);
		outputStream.popStyle();
		outputStream.endDraw();
	}

}