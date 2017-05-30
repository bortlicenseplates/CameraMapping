MapCamera mapCamera;

float realX, realY;
float realCentreX, realCentreY;
float xWeightX, yWeightX, xWeightY, yWeightY, lenseAngle;
float cameraX_theta, cameraY_theta;
float cameraX_position, cameraY_position, cameraZ_position;

float E = (float)Math.E;
float xMapExponent;
ArrayList<PVector> startpoints;
ArrayList<PVector> endpoints;
class MapCamera{
	
	
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

	void addPoints(int xIn, int yIn){
		if(trainTrackers) {
			if(clickCount%2 == 0 && singleClick){
				createStartPoint(xIn, mouseY);
				singleClick = false;
				clickCount++;
				println(startpoints.size());
			    println(endpoints.size());
			} else if(singleClick && clickCount%2 == 1){
				createEndPoint(xIn, mouseY);
				clickCount++;
				singleClick = false;
				println(startpoints.size());
			    println(endpoints.size());
			}
		}
	}

	void calibrate(){
		
	}

	void mapPoint(int x, int y){
		realX = (x*xWeightX)+(y*yWeightX);
		realX *= (abs(realX - realCentreX)*lenseAngle)+(abs(realY - realCentreY)*lenseAngle);
	}

	void testthree(int xIn, int yIn){
		if(endpoints.size()>=4 && startpoints.size() >= 4){

			// float thetaA1 = PVector.angleBetween(startpoints.get(0), startpoints.get(1));
			// float thetaB1 = PVector.angleBetween(endpoints.get(0), endpoints.get(1));
			// float thetaA2 = PVector.angleBetween(startpoints.get(2), startpoints.get(3));
			// float thetaB2 = PVector.angleBetween(endpoints.get(2), endpoints.get(3));
			// float distanceA1 = dist(startpoints.get(0).x, startpoints.get(0).y,startpoints.get(1).x, startpoints.get(1).y);
			// float distanceB1 = dist(endpoints.get(0).x, endpoints.get(0).y,endpoints.get(1).x, endpoints.get(1).y);
			// float distanceA2 = dist(startpoints.get(2).x, startpoints.get(2).y,startpoints.get(3).x, startpoints.get(3).y);
			// float distanceB2 = dist(endpoints.get(2).x, endpoints.get(2).y,endpoints.get(3).x, endpoints.get(3).y);
			// float rotation1 = thetaB1-thetaA1;
			// float rotation2 = thetaB2-thetaA2;
			float leftX = lerp(endpoints.get(0).x,endpoints.get(2).x,map(mouseY*yWeightX,startpoints.get(0).y, startpoints.get(2).y,0,1));
			float rightX = lerp(endpoints.get(1).x,endpoints.get(3).x,map(mouseY*yWeightX,startpoints.get(1).y, startpoints.get(3).y,0,1));
			realX = lerp(leftX,rightX,map(xIn*xWeightX,startpoints.get(0).x,startpoints.get(1).x,0,1));
			// float realX2 = lerp(leftX,rightX,map(xIn*xWeightX,startpoints.get(2).x,startpoints.get(3).x,0,1));
			// realX = lerp(realX1,realX2,map(mouseY,startpoints.get(0).y,startpoints.get(2).y,1,0));
			// realX = lerp(leftX,rightX,map(xIn*xWeightX,startpoints.get(0).x,startpoints.get(1).x,0,1));

			float leftY = lerp(endpoints.get(0).y,endpoints.get(1).y,map(xIn*xWeightY,startpoints.get(0).x, startpoints.get(1).x,0,1));
			float rightY = lerp(endpoints.get(2).y,endpoints.get(3).y,map(xIn*xWeightY,startpoints.get(2).x, startpoints.get(3).x,0,1));
			realY = lerp(leftY,rightY,map(mouseY*yWeightY,startpoints.get(0).y,startpoints.get(2).y,0,1));
			// float realY2 = lerp(leftY,rightY,map(mouseY*yWeightY,startpoints.get(1).y,startpoints.get(3).y,0,1));
			// realY = lerp(realY1,realY2,map(xIn,startpoints.get(0).x,startpoints.get(1).x,1,0));
			


			if(keyPressed){
						println("startX: "+xIn);
						println("realX: "+realX);
			
						println("startY: "+mouseY);
						println("realY: "+realY);
					}
		}
		// println(xMapExponent);
		// realX = (xIn*xMapExponent) + outputStream.width/2;

	}

	// void testtwo(){
	// 	if(endpoints.size()>=4 && startpoints.size() >= 4){
	// 		// setT();
	// 		float xdif = curvePoint(abs(startpoints.get(0).x - endpoints.get(0).x),abs(startpoints.get(1).x - endpoints.get(1).x),
	// 								abs(startpoints.get(2).x - endpoints.get(2).x), abs(startpoints.get(3).x - endpoints.get(3).x),
	// 								map(xIn,0,width,0,1));

	// 		float ydif = curvePoint(startpoints.get(0).y - endpoints.get(0).y,startpoints.get(1).y - endpoints.get(1).y,
	// 								startpoints.get(2).y - endpoints.get(2).y, startpoints.get(3).y - endpoints.get(3).y,
	// 								map(mouseY,0,height,1,0));
	// 		println(xdif);
	// 		realX = xdif;
	// 		realY = ydif;
	// 	}
		// println(xMapExponent);
		// realX = (xIn*xMapExponent) + outputStream.width/2;

	// }

	void test(int xIn, int yIn){
		noFill();
		stroke(255);
		// rect(100,100,500,500);
		// rect(120,120,480,480);
		// mapPoint(xIn, yIn);
		// println(realX);
		outputStream.beginDraw();
		outputStream.pushStyle();
		outputStream.background(0);
		pushStyle();
		if(trainTrackers){
			noFill();
			stroke(255);
			rect(xIn-10,yIn-10,20,20);
			outputStream.stroke(255);
			outputStream.noFill();
			outputStream.rect(xIn-10,yIn-10,20,20);
		} else {
			noFill();
			stroke(0,100,255);
			rect(xIn-10,yIn-10,20,20);
			outputStream.stroke(0,255,0);
			outputStream.noFill();
			outputStream.rect(realX-5,realY-5+lenseAngle,10,10);

		}
		
		popStyle();
		outputStream.fill(255);
		// outputStream.rect(realCentreX-10, realCentreY-10, 20, 20);
		outputStream.popStyle();
		outputStream.endDraw();
	}

}