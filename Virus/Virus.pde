import g4p_controls.*;
boolean start;
boolean quarantine = false;
StopWatchTimer flockingStopWatch = new StopWatchTimer();
ArrayList <PVector> flockingLocations;
int socialDistancingForce;
int nPeople = 350;
int nHealthy = nPeople -1;
int nSick = 1;
int nRecovered = 0;
int recoveryTime = 2000;
int width = 1920;
int height = 1080;
int boxTopX = width/75;
int boxTopY = height/50;
int boxBottomX = 4*width/5;
int boxBottomY = 49*height/50;
float margin = 75;
int virusMortalityRate;
int nDead;
int infectionProbability;

ArrayList<Wanderer> wanderers;

void setup() {
  size(1920, 1080);
  background(0);
  createGUI();
  totalLabel.setText("Total: " + nPeople);
  background(#F5F5C3);
  fill(0);
  flockingStopWatch.start();
  rectMode(CORNERS);
  rect(boxTopX, boxTopY, boxBottomX, boxBottomY, 25);
  fill(123);
  rect(boxBottomX + 25, height/3, width-25, 4*height/5);
  wanderers = new ArrayList<Wanderer>();
  wanderers.add(new Wanderer(random(boxTopX, boxBottomX), random(boxTopY, boxBottomY), sick, 1));
  for (int i = 1; i < 200; i++) {
    wanderers.add(new Wanderer(random(boxTopX, boxBottomX), random(boxTopY, boxBottomY), healthy, 1));
  }
  for (int i = 0; i < 50; i++) {
    wanderers.add(new Wanderer(random(boxTopX, boxBottomX), random(boxTopY, boxBottomY), healthy, 2));
  }
  for (int i = 0; i < 100; i++) {
    wanderers.add(new Wanderer(random(boxTopX, boxBottomX), random(boxTopY, boxBottomY), healthy, 3));
  }
  flockingLocations = new ArrayList<PVector>();
  for (int i = 0; i < 5; i++) {
    flockingLocations.add(new PVector(random(boxTopX+50, boxBottomX-50), random(boxTopY+50, boxBottomY-50)));
  }
}

void infect(Wanderer w) {
  if (w.getHealth() == sick) {
    PVector ilocation = w.getLocation();
    for (int j = 0; j < wanderers.size(); j++) {
      if (wanderers.get(j).getHealth() == healthy) {
        PVector jlocation = wanderers.get(j).getLocation();
        if (ilocation.dist(jlocation) <= 5 && (random(100) < infectionProbability)) {
          wanderers.get(j).setHealth(sick);
          nHealthy --;
          nSick ++;
        }
      }
    }
  }
}

void draw() {
  if (start == true) {
    timerLabel.setText("Time: " + millis()/1000 + "sec");
    background(#F5F5C3);
    fill(0);
    rectMode(CORNERS);
    rect(boxTopX, boxTopY, boxBottomX, boxBottomY, 25);
    fill(123);
    rect(boxBottomX + 25, height/3, width-25, 4*height/5);
    updateGUI();
    for(PVector p : flockingLocations){
      fill(0);
      stroke(123);
      circle(p.x, p.y, 100);
    }
    for (int i = 0; i < wanderers.size(); i++) {
      Wanderer w = wanderers.get(i);
      if (w.getSickDur() >= recoveryTime) {
        if (random(100)<virusMortalityRate) {
          wanderers.remove(i);
          nDead++;
          nSick--;
        } else {
          w.setHealth(recoveredColor);
          w.setSickDur(0);
          nRecovered ++;
          nSick--;
        }
      }
      if (w.getHealth() == sick)w.increaseSickDur();
      w.applyBehaviors(wanderers);
      infect(w);
      w.run();
    }
  }
    if (quarantine == true){
    stroke(204, 102, 0);
    line(boxBottomX/2,boxBottomY, boxBottomX/2,boxTopY); 
  }
}



void updateGUI() {
  healthyLabel.setText("Healthy: " + nHealthy);
  infectedLabel.setText("Infected: " + nSick);
  recoveredLabel.setText("Recovered: " +nRecovered);
  deadLabel.setText("Dead: " + nDead);
  socialDistancingForce = seperateSlider.getValueI();
  infectionProbability = infectionProbabilitySlider.getValueI();
  virusMortalityRate = virusMortalitySlider.getValueI();
}
