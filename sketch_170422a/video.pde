import processing.video.*;

public class Video extends PApplet {
  Movie myMovie;
  float magnify = 200;
  float time = 0;
  float radiusFlow = 0;
  float rotationFlow = 0;
  float colorFlow = 0;

  float rotation = 0;
  float radius = 0;
  int elements = 256;
  boolean drawWheel = false;
  com.jogamp.newt.opengl.GLWindow window;

  Timestamp resetOn;
  Spout sender;
  String name;
  public Video(String senderName) {
    this.name = senderName;
  }

  void settings () {
    size(900, 800, P3D);
  }

  void setup() {
    removeExitEvent(getSurface());
    String[] movies = new String[] {"UWH Minnesota Loons Club Swim 22 May, 2016-Usoe9pevKjQ.mp4", "UWH Minnesota Loons Club Swim 8 May 2016-g9vEAmy8eA0.mp4"};
    myMovie = new Movie2(this, "D:/" + movies[int(random(0, 2))]);
    myMovie.play();
    myMovie.volume(0);
    sender = new Spout(this);
    sender.createSender(name);
    resetOn = new Timestamp(System.currentTimeMillis() + int(random(3000, 10000)));
    rectMode(CENTER);
    colorMode(HSB);
    window = ((com.jogamp.newt.opengl.GLWindow) getSurface().getNative());
  }

  void draw() {
    if (eBeat.isOnset() && resetOn.getTime() < System.currentTimeMillis()) {
      //myMovie.speed(random(0.5, 1.8));
    }
    if (resetOn.getTime() < System.currentTimeMillis()) {
      myMovie.jump(random(myMovie.duration()));
      resetOn = new Timestamp(System.currentTimeMillis() + int(random(7000, 16000)));
      if (int(random(0, 10)) == 0) {
        drawWheel = !drawWheel;
      } else if (int(random(0, 2)) == 0) {
        //tint(random(200), 200, random(230));
      } else {
        noTint();
      }
    }
    image(myMovie, 0, 0);

    if (drawWheel) {
      setFlows();
      radius = map(radiusFlow, 0, width, 0, 10);
      rotation = map(rotationFlow, 0, height, 0, 10);
      float spacing = TWO_PI/elements ; 
      translate(width*0.5, height*0.5);
      noFill();
      strokeWeight(2);
      for (int i = 0; i < elements; i++) {
        strokeWeight(i/10);
        stroke((i+colorFlow)%255, 255, 255, i/10);
        pushMatrix();
        rotate(spacing*i*rotation);
        translate(sin(spacing*i*radius)*magnify, 0);
        ellipse(0, 0, 20, i);
        popMatrix();
      }
    }
    if (sender != null) {
      sender.sendTexture();
    }
  }

  void movieEvent(Movie m) {
    m.read();
  }
  void setFlows() {
    time += 0.1;
    radiusFlow = sin(time/77)*888;
    rotationFlow = cos(time/88)*777;
    colorFlow = sin(time/111)*255+256;
  }
  void mousePressed() {
    if (window.hasFocus()) {
      drawWheel = !drawWheel;
    }
  }
}