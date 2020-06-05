final float gravity = 9.8;
float ballRadius = 50;

float xPosition = 100;
float yPosition = 100;

float xVelocity = 100;
float yVelocity = 0;

float leftWall = 0;
float rightWall = 1000;
float floor = 600;

void setup() {
  size(1000, 1000, P3D);
}

void computePhysics(float dt) {
  // changing the x position
  xPosition += xVelocity * dt;
  if(xPosition + ballRadius > rightWall || xPosition - ballRadius < leftWall) {
    xVelocity = -xVelocity; 
    xVelocity *= 0.95;
  }
  
  // changing the y position
  // If statement put in, because otherwise, the ball would phase through the floor, balls don't do that
  if (!(yVelocity < 0.5 && yVelocity > -0.5 && yPosition + ballRadius > floor)) {
    yVelocity = yVelocity + (gravity * dt);
    yPosition += yVelocity * dt;
  }
  if(yPosition + ballRadius > floor) {
    yVelocity = -yVelocity;
    yVelocity *= 0.95;
  }
  
}

void draw() {
  background(255, 255, 100);
  rect(0, 600, 1000, 400);
  computePhysics(0.15);
  fill(0, 200, 10);
  noStroke();
  lights();
  translate(xPosition, yPosition);
  sphere(ballRadius);
}
