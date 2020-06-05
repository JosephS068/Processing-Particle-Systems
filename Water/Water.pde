float cameraX = 0;
float cameraY = 0;
float cameraZ = 0;
float cameraRX = 0;
float cameraRY = 0;
float cameraRZ = 0;

float wallX = 1000;

float alpChange = 0;
float waterRadius = 10;
int numParticles = 8000;
float genRate = 200;
float floor = 900;
int pos = 0;
int particleRecycleRate = 20;

float[][] posList = new float[numParticles][3];
float[][] velList = new float[numParticles][3];
float[][] collisionDirection = new float[numParticles][3];
boolean[] hadFirstImpact = new boolean[numParticles];
boolean[] hadWallImpact = new boolean[numParticles];
int[][] colorList = new int[numParticles][4];
float[] lifeList = new float[numParticles];
float[] zRotation = new float[numParticles];
PImage texture;
PShape bottle;

void setup() {
  size(1000, 1000, P3D);
  bottle = loadShape("Potion2_Filled.obj");
  texture = loadImage("water-small.jpg");
}

void draw() {
  background(0, 0, 0);
  
  // Handle camera position change
  keyPressed();
  translate(cameraX, cameraY, cameraZ);
  rotateX(cameraRX);
  rotateY(cameraRY);
  rotateZ(cameraRZ);
  
  // Scene creation
  noStroke();
  lights();
  createScene();
  float startFrame = millis();
  spawnParticles(0.15);
  moveParticles(0.15);
  float endParticles = millis();
  float endFrame = millis();
  String report = "Frame: " + str(endFrame-startFrame) + "ms, " + "Particles:" + str(endParticles - startFrame)+"ms, FPS:"+ str(round(frameRate));
  surface.setTitle(report);
}

void createScene() {
  fill(150, 150, 150);
  
  // Create Floor
  pushMatrix();
  translate(0, 950, 0);
  box(10000, 100, 10000);
  popMatrix();
  
  // Left Wall
  pushMatrix();
  translate(-5000, 450, 0);
  box(100, 1000, 10000);
  popMatrix();
  
  // Right Wall
  pushMatrix();
  translate(5000, 450, 0);
  box(100, 1000, 10000);
  popMatrix();
  
  // Back Wall
  pushMatrix();
  translate(0, 450, -5000);
  box(10000, 1000, 100);
  popMatrix();
  
  // Pillar for water collision
  pushMatrix();
  fill(200, 100, 100);
  translate(wallX, 450, 200);
  box(30, 1000, 500);
  popMatrix();
  
  // Potion Bottle
  pushMatrix();
  rotate(PI);
  translate(-40, -365, -1);
  rotateZ(0.7);
  scale(75);
  shape(bottle);
  popMatrix();
}

void spawnParticles(float dt) {
  float particlesToSpawn = round(dt*genRate);
  for (int i=0; i<int(particlesToSpawn); i++){
    generateRandomPosition();
  }
}

void generateRandomPosition() {
  if( pos == numParticles ){ 
    pos = 0;
  }
  
  float spawnRadius = 5;
  // Generate random radius and theta
  float r = spawnRadius * sqrt(random(spawnRadius));
  float theta = random(2*PI);
  
  // Set spawn position
  posList[pos][0] = int(r*sin(theta))+100;
  posList[pos][1] = 300;
  posList[pos][2] = int(r*cos(theta));
  
  // Set spawn velocity
  velList[pos][0] = random(30,35);
  velList[pos][1] = random(-50,-60);
  velList[pos][2] = 0;
  
  // Set particle colors
  colorList[pos][0] = 30;
  colorList[pos][1] = 30;
  colorList[pos][2] = 255;
  
  // had first impact set
  hadFirstImpact[pos] = false;
  hadWallImpact[pos] = false;
  
  // Set lifetime of particle
  lifeList[pos] = 0;
  
  // Set how the particle will act when it hits the ground
  collisionDirection[pos][0] = 100 * sin(theta);
  collisionDirection[pos][2] = 100 * cos(theta);
  
  zRotation[pos] = random(2*PI);
  pos++;
}

int particlesToDraw = 0;
void moveParticles(float dt){
  // Eventaully particles will be recycled, pos will change to a lower number, all particles should still be rendered
  if (particlesToDraw < pos) {
    particlesToDraw = pos;
  }
  for(int i = 0; i < particlesToDraw; i++){
    // Add acceleration to y velocity
    velList[i][1] += 9.8 * dt;
    
    // Update position based on velocity
    posList[i][0] += velList[i][0]*dt;
    posList[i][1] += velList[i][1]*dt;
    posList[i][2] += velList[i][2]*dt;
    
    //Update particle life
    lifeList[i] += dt;
    
    if (posList[i][1] + waterRadius > floor){
      // Reduce y velocity after impact
      posList[i][1] = floor - waterRadius;
      velList[i][1] *= -.3;
      // Handle particles first collision
      if(!hadFirstImpact[i]) {
        hadFirstImpact[i] = true;
        velList[i][0] += collisionDirection[i][0];
        velList[i][2] += collisionDirection[i][2];
      }        
    }
    
    if(posList[i][0] > wallX - 15 && (posList[i][2] > -50 && posList[i][2] < 450)) {
      velList[i][0] = 0;
      posList[i][0] = wallX - 15;
      hadWallImpact[i] = true;
    } else if (hadWallImpact[i]) {
      velList[i][0] = collisionDirection[i][0] * 0.7;
      velList[i][2] = collisionDirection[i][2] * 0.7;
    }
    
    // Draw particle and update it's color
    pushMatrix();
    float colorChangeR = colorList[i][0] + 7*lifeList[i];
    float colorChangeG = colorList[i][1] + 7*lifeList[i];
    
    if (colorChangeR > 250 ) {
      colorChangeR = 250; 
    }
    if (colorChangeG > 250 ) {
      colorChangeG = 250; 
    }
    int alpChange = int(7*lifeList[i]);
    if (alpChange > 250 ) {
      alpChange = 250; 
    }
    fill(colorChangeR, colorChangeG, colorList[i][2]);
    translate(posList[i][0],posList[i][1],posList[i][2]);
    tint(255, 255-alpChange);
    rotateY(-cameraRY);
    rotateZ(zRotation[i]);
    beginShape();
    texture(texture);
    // vertex( x, y, z, u, v) where u and v are the texture coordinates in pixels
      vertex(-10, -10, 0, 0, 0);
      vertex(10, -10, 0, 50, 0);
      vertex(10, 10, 0, 50, 50);
      vertex(-10, 10, 0, 0, 50);
    endShape();
    popMatrix();
  }
}

void keyPressed() {
  if (keyPressed && keyCode == DOWN){
    cameraZ -= 10;
  }
  if (keyPressed && keyCode == UP){
    cameraZ += 10;
  }
  if (keyPressed && keyCode == LEFT){
    cameraX += 10;
  }
  if (keyPressed && keyCode == RIGHT){
    cameraX -= 10;
  }
  if (keyPressed && keyCode == ENTER){
    cameraY += 10;
  }
  if (keyPressed && keyCode == SHIFT){
    cameraY -= 10;
  }
    if (keyPressed && (key == 'e' || key == 'E')){
    cameraRZ -= PI/64;
  }
  if (keyPressed && key == 'q' || key == 'Q'){
    cameraRZ += PI/64;
  }
  if (keyPressed && key == 's' || key == 'S'){
    cameraRX += PI/64;
  }
  if (keyPressed && key == 'w' || key == 'W'){
    cameraRX -= PI/64;
  }
  if (keyPressed && key == 'a' || key == 'A'){
    cameraRY += PI/64;
  }
  if (keyPressed && key == 'd' || key == 'D'){
    cameraRY -= PI/64;
  }
  
  if (keyPressed && key == 'y' || key == 'Y'){
    wallX += 10;
  }
  if (keyPressed && key == 'u' || key == 'U'){
    wallX -= 10;
  }
}

//Water texture source
// https://www.flickr.com/photos/freefoto/1239764571/in/photostream/
