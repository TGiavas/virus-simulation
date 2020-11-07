color healthy = color(0, 255, 0);
color sick = color(255, 0, 0);
color recoveredColor = color(0, 0, 255);

class Wanderer {
  int wandererType; //1 = wanderer, 2 = immobile, 3 = flocker
  int sickDur = 0;
  color health = healthy;
  PVector location;
  PVector velocity;
  PVector acceleration;
  float r;
  float wandertheta;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed

  Wanderer(float x, float y, color c, int wandererType) {
    health = c;
    acceleration = new PVector(0, 0);
    velocity = new PVector(0, 0);
    location = new PVector(x, y);
    r = 7;
    wandertheta = 0;
    maxspeed = 2;
    maxforce = 0.05;
    this.wandererType = wandererType;
  }

  void run() {
    update();
    display();
  }

  void applyBehaviors(ArrayList<Wanderer> wanderers) {
    PVector quarantineForce = quarantine();
    PVector separateForce = separate(wanderers);
    PVector wanderForce = wander();
    PVector boundariesForce = boundaries();
    PVector flockForce = flock();
    separateForce.mult(socialDistancingForce);
    boundariesForce.mult(10);
    wanderForce.mult(1);
    if (quarantine == true) {
      quarantineForce.mult(10);
    }
    else if (quarantine == false){
      quarantineForce.mult(0);
    }
    if (flockingStopWatch.second()%10 >= 5) {
      flockForce.mult(2);
    } else flockForce.mult(0);
    if (wandererType == 1) {
      applyForce(wanderForce);
      applyForce(separateForce);
    } else if (wandererType == 2) {
      applyForce(boundariesForce);
    } else {
      applyForce(flockForce);
      applyForce(wanderForce);
      applyForce(separateForce);
    }
    // wanderForce.mult(1);
    applyForce(boundariesForce);
    applyForce(quarantineForce);
    //flockForce.mult(5);
  }

  // Method to update location
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    location.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }

  PVector wander() {
    float wanderR = 25;         // Radius for our "wander circle"
    float wanderD = 80;         // Distance for our "wander circle"
    float change = 0.3;
    wandertheta += random(-change, change);     // Randomly change wander theta

    // Now we have to calculate the new location to steer towards on the wander circle
    PVector circleloc = velocity.get();    // Start with velocity
    circleloc.normalize();            // Normalize to get heading
    circleloc.mult(wanderD);          // Multiply by distance
    circleloc.add(location);               // Make it relative to boid's location

    float h = velocity.heading2D();        // We need to know the heading to offset wandertheta

    PVector circleOffSet = new PVector(wanderR*cos(wandertheta+h), wanderR*sin(wandertheta+h));
    PVector target = PVector.add(circleloc, circleOffSet);
    return seek(target);
  }  

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }


  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, location);  // A vector pointing from the location to the target

    // Normalize desired and scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);
    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  void display() {
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading2D() + radians(90);
    stroke(0);
    pushMatrix();
    fill(health);
    translate(location.x, location.y);
    ellipse(0, 0, r, r);
    //rotate(theta);
    //beginShape();
    //vertex(3, 2);
    //vertex(8.5, 2);
    //vertex(8.5, 7.5);
    //vertex(3, 7.5);
    //endShape();
    //endShape();
    popMatrix();
  }

  PVector separate (ArrayList<Wanderer> wanderers) {
    float desiredseparation = r*2;
    PVector sum = new PVector();
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Wanderer other : wanderers) {
      float d = PVector.dist(location, other.location);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(location, other.location);
        diff.normalize();
        diff.div(d);        // Weight by distance
        sum.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      sum.div(count);
      // Our desired vector is the average scaled to maximum speed
      sum.normalize();
      sum.mult(maxspeed);
      // Implement Reynolds: Steering = Desired - Velocity
      sum.sub(velocity);
      sum.limit(maxforce);
    }
    return sum;
  }

  PVector boundaries() {
    PVector desired = null;
    if (location.x > boxBottomX - margin/2) {
      desired = new PVector(-maxspeed, velocity.y);
    } else if (location.x < boxTopX  + margin/2) {
      desired = new PVector(maxspeed, velocity.y);
    } 
    if (location.y < boxTopY + margin/2) {
      desired = new PVector(velocity.x, maxspeed);
    } else if (location.y > boxBottomY-margin/2) {
      desired = new PVector(velocity.x, -maxspeed);
    } 

    if (desired != null) {
      desired.normalize();
      desired.mult(maxspeed);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(maxforce);
      return steer;
    }
    return new PVector(0, 0);
  }

  PVector quarantine() {
    PVector desired = null;
    if (location.x > boxBottomX/2 && location.x <boxBottomX/2+50) {
      desired = new PVector(maxspeed, velocity.y);
    } else if (location.x < boxBottomX/2 && location.x > boxBottomX/2-50) {
      desired = new PVector(-maxspeed, velocity.y);
    } 

    if (desired != null) {
      desired.normalize();
      desired.mult(maxspeed);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(maxforce);
      return steer;
    }
    return new PVector(0, 0);
  }
  PVector flock () {
    PVector target = flockingLocations.get(0);
    for (int i = 0; i < flockingLocations.size(); i++) {
      if (this.location.dist(flockingLocations.get(i))< this.location.dist(target)) {
        target = flockingLocations.get(i);
      }
    }
    return seek(target);
  }
  void setHealth(color c) {
    health = c;
  }

  color getHealth() {
    return health;
  }

  PVector getLocation() {
    return location;
  }

  void increaseSickDur() {
    sickDur ++;
  }

  int getSickDur() {
    return sickDur;
  }

  void setSickDur(int dur) {
    sickDur = dur;
  }
}
