import ddf.minim.*;
import ddf.minim.analysis.*;
import javax.sound.sampled.*;
import java.util.Arrays;
import java.util.Map;
import java.util.Collections;
import spout.*;
import java.util.Comparator;


Minim minim;
AudioInput in;
FFT fft;
float spectrumScale = 4;
float height3;
float height23;
FFT fftLin;
FFT fftLog;
FFT fftLin2;
FFT fftLog2;
BeatDetect beat;
BeatDetect eBeat;
BeatListener bl;
Spout spout;
float eRadius;
int[] major = new int[] {121, 250, 3};
int[] minor = new int[] {3, 36, 250};
Freq[] linFreqs;
Freq[] logFreqs;
float kickSize, snareSize, hatSize;
int[] kickParams;
int[] snareParams;
int[] hatParams;
int[][] quadrantBoundaries;
Sphere sa;
Map<String, PApplet> sketches;
Map<String, float[]> sketchCoords;
Map<String, Object> analysis;


void settings() {
  size(700, 600, P3D);
}
void setup () {
  height3 = height/3;
  height23 = 2*height/3;

  minim = new Minim(this);
  for (Mixer.Info m : AudioSystem.getMixerInfo()) {
    if (m.getName().startsWith("Primary Capture")) {
      minim.setInputMixer(AudioSystem.getMixer(m));
      break;
    }
  }
  in = minim.getLineIn(Minim.STEREO, 4096);
  //frameRate(1);
  rectMode(CORNERS);
  fft = new FFT(in.bufferSize(), in.sampleRate());
  // create an FFT object that has a time-domain buffer the same size as jingle's sample buffer
  // note that this needs to be a power of two 
  // and that it means the size of the spectrum will be 1024. 
  // see the online tutorial for more info.
  fftLin = new FFT( in.bufferSize(), in.sampleRate() );
  fftLin2 = new FFT( in.bufferSize(), in.sampleRate() );


  // calculate the averages by grouping frequency bands linearly. use 30 averages.
  fftLin.linAverages( 30 );
  fftLin2.linAverages( 30 );

  // create an FFT object for calculating logarithmically spaced averages
  fftLog = new FFT( in.bufferSize(), in.sampleRate() );
  fftLog2 = new FFT( in.bufferSize(), in.sampleRate() );

  // calculate averages based on a miminum octave width of 22 Hz
  // split each octave into three bands
  // this should result in 30 averages
  fftLog.logAverages( 22, 3 );
  fftLog2.logAverages( 22, 3 );
  beat = new BeatDetect(in.bufferSize(), in.sampleRate());
  eBeat = new BeatDetect();
  eBeat.setSensitivity(1);
  ellipseMode(RADIUS);
  eRadius = 20;
  //beat.setSensitivity(300);
  bl = new BeatListener(beat, in);
  stroke(256, 256, 256);
  background(0);
  sketches = Collections.synchronizedMap(new HashMap<String, PApplet>());
  sketchCoords = Collections.synchronizedMap(new HashMap<String, float[]>());
  noFill();
  noLoop();
}

void draw() {
  background(0);
  int d = 10;
  int w = 100;
  int h = 60;
  int r = 0;
  int c = 0;
  sketchCoords.clear();
  float[] coords;
  for (String key : sketches.keySet()) {
    coords = calcGridCoords(d, w, h, r, c);
    if ((coords[0] + d + w) > width) {
      r++;
      c = 0;
      coords = calcGridCoords(d, w, h, r, c);
    }

    rect(coords[0], coords[1], coords[2], coords[3]);
    text(key, coords[0] + w/4, coords[1] + h/2);
    c++;
    //println("x1 " + x1 + " d " + d + " w " + w + " width " + width + " " + (x1 + d + w));
    sketchCoords.put(key, coords);
  }
}

void keyPressed() {
  if (key == 's') {
    createSketch("sphere");
    redraw();
  } else if (key == 't') {
    createSketch("turbulence");
    redraw();
  } else if (key == 'v') {
    createSketch("video");
    redraw();
  } else if (key == 'f') {
    createSketch("flock");
    redraw();
  } else if (key == 'c') {
    createSketch("catcher");
    redraw();
  } else if (key == 'w') {
    createSketch("wheel");
    redraw();
  } else if (key == 'g') {
    createSketch("grid");
    redraw();
  } else if (key == 'b') {
    createSketch("beatanalyzer");
    redraw();
  } else if (key == 'x') {
    for (String key : sketches.keySet()) {
      sketches.get(key).dispose();
      sketches.get(key).getSurface().setVisible(false);
      sketches.remove(key);
    }
    redraw();
  }
  //println(keyCode);
}

void mousePressed() {
  for (String key : sketchCoords.keySet()) {
    float[] coords = sketchCoords.get(key);
    if (mouseX >= coords[0] && mouseX <= coords[2] && mouseY >= coords[1] && mouseY <= coords[3]) {
      if (sketches.get(key).getSurface().getNative().getClass().getName().contains("GLWindow"))
        ((com.jogamp.newt.opengl.GLWindow) sketches.get(key).getSurface().getNative()).destroy();
      else {
        ((processing.awt.PSurfaceAWT.SmoothCanvas) sketches.get(key).getSurface().getNative()).setVisible(false);
      }
      sketches.get(key).dispose();
      //sketches.get(key).getSurface().setVisible(false);
      sketches.remove(key);
      redraw();
    }
  }
}

PApplet sketchFactory(String name) {
  PApplet s = null;
  if (name.startsWith("sphere")) {
    s = new Sphere(name);
  } else if (name.startsWith("turbulence")) {
    s = new Turbulence(name);
  } else if (name.startsWith("video")) {
    s = new Video(name);
  } else if (name.startsWith("flock")) {
    s = new Flock(name);
  } else if (name.startsWith("catcher")) {
    s = new Catcher(name);
  } else if (name.startsWith("wheel")) {
    s = new Wheel(name);
  } else if (name.startsWith("grid")) {
    s = new CGrid(name);
  } else if (name.startsWith("beatanalyzer")) {
    s = new BeatAnalyzer(name);
  }
  return s;
}

PApplet createSketch(String type) {
  PApplet sketch = null;
  int max = 0;
  for (String key : sketches.keySet()) {
    if (key.startsWith(type)) {
      int num = Integer.parseInt(key.substring(key.length() - 1));
      if (num > max) {
        max = num;
      }
    }
  }
  max++;
  String name = type + max;
  sketch = sketchFactory(name);
  sketches.put(name, sketch);
  PApplet.runSketch(new String[] {name}, sketch);
  sketch.getSurface().setTitle(name);
  return sketch;
}

float[] calcGridCoords(int d, int w, int h, int r, int c) {
  float[] coords = new float[4];
  coords[0] = d * (c + 1) + w*c; //x1
  coords[1] = d * (r+1) + h*r;  //y1
  coords[2] = (d + w) * (c + 1); //x2
  coords[3] = (d + h) * (r + 1); //y2
  return coords;
}


static final void removeExitEvent(final PSurface surf) {
  if (surf.getNative().getClass().getName().contains("GLWindow")) {
    final com.jogamp.newt.Window win
      = ((com.jogamp.newt.opengl.GLWindow) surf.getNative());
    //final java.awt.Window win
    //=((processing.awt.PSurfaceAWT.SmoothCanvas) surf.getNative()).getFrame();

    for (final com.jogamp.newt.event.WindowListener evt : win.getWindowListeners())
      win.removeWindowListener(evt);
  }
  //for (final java.awt.event.WindowListener evt : win.getWindowListeners())
  //win.removeWindowListener(evt);
}