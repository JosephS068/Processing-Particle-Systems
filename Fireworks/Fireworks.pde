float cameraX = 400;
float cameraY = 800;
float cameraZ = -1500;
float cameraRX = 0;
float cameraRY = 0;
float cameraRZ = 0;

int numParticles = 30000;
int numFireworks = 30;
int particlesPerFirework = numParticles / numFireworks;
int activeFireworks = 0;
int despawnRate = 15;
int colorChangeRate = 7;
int timeToExplode = 8;
Firework[] fireworks = new Firework[numFireworks];

float totalTime = 0;

PShape bullet;
PShape gun;

void setup() {
  size(1000, 1000, P3D);
  spawnParticles();
  bullet = loadShape("bullet.obj");
  gun = loadShape("ray-gun.obj");
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
  if ((keyPressed && key == 'f' || key == 'F') && activeFireworks < numFireworks){
    fireworks[activeFireworks].startedTime = totalTime;
    activeFireworks += 1;
  }
  
  float dt = 0.15;
  totalTime += dt;
  for (int i=0; i<activeFireworks; i++) {
    fireworks[i].moveParticles(dt);
  }
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
  
  // Creates guns
  pushMatrix();
  translate(0,880, 0);
  scale(200);
  rotateX(3 * PI/2);
  gun.setFill(color(255,0,0));
  shape(gun);
  popMatrix();
  
  pushMatrix();
  translate(150,880, 0);
  scale(200);
  rotateX(3 * PI/2);
  gun.setFill(color(0,255,0));
  shape(gun);
  popMatrix();
  
  pushMatrix();
  translate(300,880, 0);
  scale(200);
  rotateX(3 * PI/2);
  gun.setFill(color(0,0,255));
  shape(gun);
  popMatrix();
}

void spawnParticles() {
  int bulletOffset = 0;
  for (int i=0; i<numFireworks; i++){
    fireworks[i] = new Firework(bulletOffset);
    bulletOffset += 150;
    if (bulletOffset > 300) {
      bulletOffset = 0;
    }
  }
}

class Firework { 
  float[][] posList = new float[particlesPerFirework][3];
  float[][] velList = new float[particlesPerFirework][3];
  int[][] colorList = new int[particlesPerFirework][4];
  float[] lifeList = new float[particlesPerFirework];
  float[] zRotation = new float[particlesPerFirework];
  float startedTime = 0;
  float[] position = new float[3];
  int bulletOffset = 0;

  Firework (int bulletOffset) {
    this.bulletOffset = bulletOffset;
    position[0] = -80;
    position[1] = 500;
    position[2] = -180;
    
    for (int i=0; i<particlesPerFirework; i++){
      generateRandomPosition(i);
    }
  } 
  
  void generateRandomPosition(int pos) {  
    // Generate random position on sphere
    float spawnRadius = 100;
    float r = sqrt(spawnRadius * random(spawnRadius));
    float theta = random(2*PI);
    
    // Set spawn position
    posList[pos][0] = int(r*sin(theta));
    posList[pos][2] = int(r*cos(theta));
    
    float yPosition = (posList[pos][0] * posList[pos][0]) + (posList[pos][2] * posList[pos][2]);
    yPosition = sqrt(yPosition);
    yPosition = (spawnRadius * spawnRadius) - (yPosition * yPosition);
    yPosition = sqrt(yPosition);
    posList[pos][1] = yPosition;
    
    float sign = random(2);
    if (sign > 1) { 
      posList[pos][1] = -posList[pos][1];
    }
    
    // Set spawn velocity
    if(pos <= particlesPerFirework/3){
      velList[pos][0] = posList[pos][0] * 0.8;
      velList[pos][1] = posList[pos][1] * 0.8;
      velList[pos][2] = posList[pos][2] * 0.8;
    }else if(pos> particlesPerFirework/3 && pos< particlesPerFirework*2/3){
      velList[pos][0] = posList[pos][0] * 0.7 * random(0.9,1.1);
      velList[pos][1] = posList[pos][1] * 0.7 * random(0.9,1.1);
      velList[pos][2] = posList[pos][2] * 0.7 * random(0.9,1.1);
    }else{
      velList[pos][0] = posList[pos][0] * 0.3;
      velList[pos][1] = posList[pos][1] * 0.3;
      velList[pos][2] = posList[pos][2] * 0.3;
    }
    
    // Set particle colors

    // Color Configuration 
    if(pos<= particlesPerFirework/3){
      colorList[pos][0] = int(random(20));
      colorList[pos][1] = int(random(20));
      colorList[pos][2] = int(random(100,255));
    }else if(pos> particlesPerFirework/3 && pos< particlesPerFirework*2/3){
      colorList[pos][0] = int(random(100,255));
      colorList[pos][1] = int(random(20));
      colorList[pos][2] = int(random(20));
    }else{
      colorList[pos][0] = int(random(100,215));
      colorList[pos][1] = int(random(107,147));
      colorList[pos][2] = int(random(48,52));
    }
    // Set lifetime of particle
    if(pos<= particlesPerFirework/3){
      lifeList[pos] = 0;
    }else if(pos> particlesPerFirework/3 && pos< particlesPerFirework*2/3){
      lifeList[pos] = 1;
    }else{
      lifeList[pos] = 7;
    }
  }
  
  void moveParticles(float dt) {
    if(startedTime + timeToExplode > totalTime) {
      projectile(dt);
    } else {
      explosion(dt);
    }
  }
  
  float bulletVelocity = -250;
  void projectile(float dt) {
    // Add acceleration to y velocity
    bulletVelocity += 9.8 * dt;
    position[1] += bulletVelocity * dt;
    
    pushMatrix();
    translate(position[0]+bulletOffset, position[1]+25, position[2]-60);
    rotateX(PI/2);
    scale(35);
    shape(bullet);
    popMatrix();
  }
  
  int deletedParticles = 0;
  void explosion(float dt) {
    int particlesToDraw = particlesPerFirework;
    if (startedTime + timeToExplode + 4 < totalTime) {
      particlesToDraw = particlesPerFirework;
    } else if(startedTime + timeToExplode + 1 < totalTime) {
      particlesToDraw = particlesPerFirework * 2/3;
    } else {
      particlesToDraw = particlesPerFirework * 1/3;
    }
    
    for(int i = deletedParticles; i < particlesToDraw; i++){
      //Update particle life
      lifeList[i] += dt;
      
      // Add acceleration to y velocity
      velList[i][1] += 3 * dt;
      
      // Update position based on velocity
      posList[i][0] += velList[i][0]*dt;
      posList[i][1] += velList[i][1]*dt;
      posList[i][2] += velList[i][2]*dt;
      
    int alpChange = int(despawnRate*lifeList[i]);
      if (alpChange > 255 ) {
        alpChange = 255; 
      }
      int colChangeR = int(colorChangeRate*lifeList[i]);
      if (colChangeR > 255 ) {
        colChangeR = 255; 
      }
      int colChangeB = int(colorChangeRate*lifeList[i]);
      if (colChangeB > 255 ) {
        colChangeR = 255; 
      }
      
      // translate to specific firework location
      pushMatrix();
      translate(position[0]+bulletOffset, position[1], position[2]);
      
      pushMatrix();
      fill(colorList[i][0] + colChangeR, colorList[i][1], colorList[i][2]+colChangeB, 255-alpChange);
      translate(posList[i][0], posList[i][1], posList[i][2]);
      ellipse(0, 0, 15 - lifeList[i], 15 - lifeList[i]);
      popMatrix();
      popMatrix();
      if(lifeList[i] * despawnRate >= 255) {
        deletedParticles++;
      }
    }
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
}

//Water texture source
// https://www.flickr.com/photos/freefoto/1239764571/in/photostream/
