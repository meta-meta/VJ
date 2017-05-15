//Raven Kwok aka Guo, Ruiwen
//ravenkwok.com
//vimeo.com/ravenkwok
//flickr.com/photos/ravenkwok

import java.sql.Timestamp;

public class Turbulence extends PApplet {

  ArrayList<Particle> pts;
  boolean onPressed;
  PFont f;
  Timestamp releaseOn;
  float curX;
  float curY;
  float newX;
  float newY;
  int[][] quadrantBoundaries;
  com.jogamp.newt.opengl.GLWindow window;
  Spout sender;
  String senderName;
  int triggerCount;
  long lastTriggered;


  public Turbulence(String sender) {
    senderName = sender;
  }
  void settings() {
    size(720, 720, P2D);
  }
  void setup() {
    removeExitEvent(getSurface());
    smooth();
    frameRate(30);
    colorMode(HSB);
    rectMode(CENTER);
    pts = new ArrayList<Particle>();

    f = createFont("Calibri", 24, true);

    background(0);
    curX = width/2;
    curY = height/2;
    quadrantBoundaries = new int[][] {new int[] {0, width/2, height/2, height}, new int[] {width/2, width, height/2, height}, new int[] {0, width/2, 0, height/2}, new int[] {width/2, width, 0, height/2}};
    window = ((com.jogamp.newt.opengl.GLWindow) getSurface().getNative());
    releaseOn = new Timestamp(System.currentTimeMillis());
    sender = new Spout(this);
    sender.createSender(senderName);
    triggerCount = 0;
    lastTriggered = Long.MAX_VALUE;
  }

  void mousePressed() {
    if (window.hasFocus()) {
      onPressed = true;
      lastTriggered = System.currentTimeMillis();
    }
  }

  void mouseReleased() {
    if (window.hasFocus()) {
      onPressed = false;
    }
  }

  void draw() {
    Timestamp now = new Timestamp(System.currentTimeMillis());
    if (window.hasFocus()) {
      curX = mouseX;
      curY = mouseY;
    } else if (eBeat.isOnset() || (System.currentTimeMillis() - lastTriggered) > 7000) {
      if (!onPressed && int(random(0, 5)) == 0 && releaseOn.before(now)) {
        onPressed = true;
        lastTriggered = System.currentTimeMillis();
        releaseOn = new Timestamp(now.getTime() + int(random(2000, 5000)));
      }
      int quad = 0;
      for (int i = 0; i < quadrantBoundaries.length; i++) {
        if (curX >= quadrantBoundaries[i][0] && curX <= quadrantBoundaries[i][1] && curY >= quadrantBoundaries[i][2] && curY <= quadrantBoundaries[i][3]) {
          quad = i;
          break;
        }
      }
      int newQuad = quad;
      while (newQuad == quad) {
        newQuad = int(random(0, 3));
      }
      curX = int(random(quadrantBoundaries[newQuad][0], quadrantBoundaries[newQuad][1]));
      curY = int(random(quadrantBoundaries[newQuad][2], quadrantBoundaries[newQuad][3]));
      triggerCount++;
    }
    if (releaseOn.before(now)) {
      onPressed = false;
    }
    if (onPressed) {
      for (int i=0; i<10; i++) {
        Particle newP = new Particle(curX, curY, i+pts.size(), i+pts.size());
        pts.add(newP);
      }
    }

    for (int i=0; i<pts.size(); i++) {
      Particle p = pts.get(i);
      p.update();
      p.display();
    }

    for (int i=pts.size()-1; i>-1; i--) {
      Particle p = pts.get(i);
      if (p.dead) {
        pts.remove(i);
      }
    }
    if (triggerCount > 35) {
      reset();
      triggerCount = 0;
    }
    if (sender != null) {
      sender.sendTexture();
    }
  }
  void keyPressed() {
    if (key == 'c') {
      reset();
    }
  }


  void reset() {
    for (int i=pts.size()-1; i>-1; i--) {
      Particle p = pts.get(i);
      pts.remove(i);
    }
    background(0);
  }

  class Particle {
    PVector loc, vel, acc;
    int lifeSpan, passedLife;
    boolean dead;
    float alpha, weight, weightRange, decay, xOffset, yOffset;
    color c;

    Particle(float x, float y, float xOffset, float yOffset) {
      loc = new PVector(x, y);

      float randDegrees = random(360);
      vel = new PVector(cos(radians(randDegrees)), sin(radians(randDegrees)));
      vel.mult(random(5));

      acc = new PVector(0, 0);
      lifeSpan = int(random(30, 90));
      decay = random(0.75, 0.9);
      c = color(random(255), random(255), 255);
      weightRange = random(3, 50);

      this.xOffset = xOffset;
      this.yOffset = yOffset;
    }

    void update() {
      if (passedLife>=lifeSpan) {
        dead = true;
      } else {
        passedLife++;
      }

      alpha = float(lifeSpan-passedLife)/lifeSpan * 70+50;
      weight = float(lifeSpan-passedLife)/lifeSpan * weightRange;

      acc.set(0, 0);

      float rn = (noise((loc.x+frameCount+xOffset)*0.01, (loc.y+frameCount+yOffset)*0.01)-0.5)*4*PI;
      float mag = noise((loc.y+frameCount)*0.01, (loc.x+frameCount)*0.01);
      PVector dir = new PVector(cos(rn), sin(rn));
      acc.add(dir);
      acc.mult(mag);

      float randDegrees = random(360);
      PVector randV = new PVector(cos(radians(randDegrees)), sin(radians(randDegrees)));
      randV.mult(0.5);
      acc.add(randV);

      vel.add(acc);
      vel.mult(decay);
      vel.limit(3);
      loc.add(vel);
    }

    void display() {
      strokeWeight(weight+1.5);
      stroke(0, alpha);
      point(loc.x, loc.y);

      strokeWeight(weight);
      stroke(c);
      point(loc.x, loc.y);
    }
  }
}