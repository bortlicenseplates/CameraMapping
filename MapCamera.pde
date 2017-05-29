MapCamera mapCamera;

float realX, realY;
float realCentreX, realCentreY;
float xWeight, yWeight, lenseAngle;
float E = (float)Math.E;
float xMapExponent;
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

	void setT(){
		float[] t = new float[2];
		float[] y = new float[2];
		for(int i = 0; i < 2; i++){
			t[i] = abs((startpoints.get(i).x - width/2)-(endpoints.get(i).x - width/2));
			y[i] = startpoints.get(i).x;
		}
		xMapExponent = getExponent(t[0], t[1],y[0],y[1]);
	}

	float getExponent(float t1, float t2, float y1, float y2){
		return E*((log(y1) - log(y2))/(t1 - t2));
	}


	///IGNORE FOR NOW

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
		
	}

	void mapPoint(int x, int y){
		realX = (x*xWeight)+(y*yWeight);
		realX *= (abs(realX - realCentreX)*lenseAngle)+(abs(realY - realCentreY)*lenseAngle);
	}

	void testthree(){
		if(endpoints.size()>=4 && startpoints.size() >= 4){
			float thetaA1 = PVector.angleBetween(startpoints.get(0), startpoints.get(1));
			float thetaB1 = PVector.angleBetween(endpoints.get(0), endpoints.get(1));
			float distanceA1 = dist(startpoints.get(0).x, startpoints.get(0).y,startpoints.get(1).x, startpoints.get(1).y);
			float distanceB1 = dist(endpoints.get(0).x, endpoints.get(0).y,endpoints.get(1).x, endpoints.get(1).y);
			float rotation1 = thetaB1-thetaA1;
			// realX = lerp(0,distanceB1,map(mouseX,startpoints.get(0).x,mouseX,startpoints.get(1).x,0,1));
		}
		// println(xMapExponent);
		// realX = (mouseX*xMapExponent) + outputStream.width/2;

	}

	void testtwo(){
		if(endpoints.size()>=4 && startpoints.size() >= 4){
			// setT();
			float xdif = curvePoint(abs(startpoints.get(0).x - endpoints.get(0).x),abs(startpoints.get(1).x - endpoints.get(1).x),
									abs(startpoints.get(2).x - endpoints.get(2).x), abs(startpoints.get(3).x - endpoints.get(3).x),
									map(mouseX,0,width,0,1));

			float ydif = curvePoint(startpoints.get(0).y - endpoints.get(0).y,startpoints.get(1).y - endpoints.get(1).y,
									startpoints.get(2).y - endpoints.get(2).y, startpoints.get(3).y - endpoints.get(3).y,
									map(mouseY,0,height,1,0));
			println(xdif);
			realX = xdif;
			realY = ydif;
		}
		// println(xMapExponent);
		// realX = (mouseX*xMapExponent) + outputStream.width/2;

	}

	void test(){
		// mapPoint(mouseX, mouseY);
		// println(realX);
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
		// outputStream.rect(realCentreX-10, realCentreY-10, 20, 20);
		outputStream.popStyle();
		outputStream.endDraw();
	}

}