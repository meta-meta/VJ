import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;
boolean showImage;
PImage img;

void setupCam() {
  //size(640, 480);
  video = new Capture(this, 640/2, 480/2);
  opencv = new OpenCV(this, 640/2, 480/2);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  

  video.start();
  showImage = false;
  img = loadImage("bada.png");
}

void drawCam() {
  scale(2);
  opencv.loadImage(video);

  image(video, 0, 0 );

  noFill();
  stroke(0, 255, 0);
  strokeWeight(3);
  Rectangle[] faces = opencv.detect();
  //println(faces.length);

  for (int i = 0; i < faces.length; i++) {
    //println(faces[i].x + "," + faces[i].y);
    if (showImage) {
      if (eBeat.isOnset()) {
        pushMatrix();
        //translate(faces[i].x + faces[i].width/2, faces[i].y + faces[i].height/2);
        rotate(PI/random(0, 5));
        image(img, faces[i].x, faces[i].y, faces[i].width, faces[i].height);
        popMatrix();
      } else {
        image(img, faces[i].x, faces[i].y, faces[i].width, faces[i].height);
      }
    }
    //rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
  }
}


void captureEvent(Capture c) {
  c.read();
}