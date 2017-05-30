// smoothBox::
// 	float xyIn, float xyOut
// 	float x, y, width, height;
// 	float smoothingFactor << 0->1 >>

// 	PVector boundingBox(int xIn, int yIn){
// 		if(xIn && yIn -> !inside box){
// 			xOut = lerp(previousX,xIn,smoothingFactor)
// 		}
// 		previousX, previousY = xOut, yOut
// 	}

class SmoothBox{
	float smoothedX, smoothedY;
	float previousX;
	float previousY;
	float edgeX, edgeY;
	float smoothingFactorX, smoothingFactorY;
	float timer;
	SmoothBox(){

	}

	float smoothingBoxX(float x, float boxSize, float smoothX){
		float halfBox = boxSize/2;
		float checker = abs(previousX-halfBox);
		if((-checker<x-halfBox || checker > x+ halfBox) && abs(previousX-x) > halfBox){
			// println(abs(x-previousX)>mouseX-halfBox); 
			smoothedX = smoothedX(x,smoothX);
			previousX = smoothedX;
			edgeX = smoothedX;
			return smoothedX;
		} else {
			if((edgeX-x) > 5){
				previousX = lerp(previousX, edgeX-halfBox, smoothX/100);
			} else if((edgeX-x) < -5){
				previousX = lerp(previousX, edgeX+halfBox, smoothX/100);
			}
		}
		
		return previousX;
	}

	float smoothingBoxY(float y, float boxSize, float smoothY){
		float halfBox = boxSize/2;
		float checker = abs(previousY-halfBox);
		if((-checker<y-halfBox || checker > y+ halfBox) && abs(previousY-y) > halfBox){
			// println(abs(x-previousX)>mouseX-halfBox); 
			smoothedY = smoothedY(y,smoothY);
			previousY = smoothedY;
			edgeY = smoothedY;
			return smoothedY;
		} else {
			if((edgeY-y) > 5){
				previousY = lerp(previousY, edgeY-halfBox, smoothY/100);
			} else if((edgeY-y) < -5){
				previousY = lerp(previousY, edgeY+halfBox, smoothY/100);
			}
		}
		
		return previousY;
	}

	//enter x position, enter percent of difference between x and prevoius x to move by
	float smoothedX(float x, float smoothingFactor){
		smoothingFactor = constrain(smoothingFactor/100, 0, 1);
		return lerp(previousX, x, smoothingFactor);
	}

	float smoothedY(float y, float smoothingFactor){
		smoothingFactor = constrain(smoothingFactor/100, 0, 1);
		return lerp(previousY, y, smoothingFactor);
	}


}
SmoothBox smoothBox;
void testSmoothBoxSetup(){
	smoothBox = new SmoothBox();
}

void testSmoothBox(){
	pushMatrix();
	pushStyle();
	float xpos = smoothBox.smoothingBoxX(mouseX,100,2);
	float ypos = smoothBox.smoothingBoxY(mouseY,100,2);
	rectMode(CENTER);
	rect(xpos,ypos,100,100);
	popStyle();
	popMatrix();
}