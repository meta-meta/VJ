public class BeatAnalyzer extends PApplet {
  com.jogamp.newt.opengl.GLWindow window;
  void settings() {
    size(700, 600, P3D);
  }
  public BeatAnalyzer(String name) {
  }
  void setup() {
    removeExitEvent(getSurface());
    rectMode(CORNERS);
    noFill();
    window = ((com.jogamp.newt.opengl.GLWindow) getSurface().getNative());
  }
  void draw() {
    drawBeatDetect();
  }
  void drawFFT() {
    background(0);
    int d = 30;
    int w = 50;
    int h = 10;
    int r = 0;
    int c = 0;
    float[] coords;
    for (int i = 0; i < fftLin.specSize(); i++) {
      coords = calcGridCoords(d, w, h, r, c);
      if ((coords[0] + d + w) > width) {
        r++;
        c = 0;
        coords = calcGridCoords(d, w, h, r, c);
      }
      rect(coords[0], coords[1], coords[2], coords[3]);
      String label = String.format("%.2f", fftLin.indexToFreq(i));
      text(label, coords[0], coords[1]);
      text(String.format("%.2f", fftLin.getBand(i)), coords[0], coords[1] + 10);
      c++;
      //println("x1 " + x1 + " d " + d + " w " + w + " width " + width + " " + (x1 + d + w));
    }
    for (int i = 0; i < fftLin.avgSize(); i++) {
      coords = calcGridCoords(d, w, h, r, c);
      if ((coords[0] + d + w) > width) {
        r++;
        c = 0;
        coords = calcGridCoords(d, w, h, r, c);
      }
      rect(coords[0], coords[1], coords[2], coords[3]);
      String label = String.format("%.2f", fftLin.getAverageCenterFrequency(i));
      text(label, coords[0], coords[1]);
      text(String.format("%.2f", fftLin.getAvg(i)), coords[0], coords[1] + 10);
      c++;
      //println("x1 " + x1 + " d " + d + " w " + w + " width " + width + " " + (x1 + d + w));
    }
  }
  void drawBeatDetect() {
    background(0);
    int d = 5;
    int w = 50;
    int h = 30;
    int r = 0;
    int c = 0;
    float[] coords;
    for (int i = 0; i < beat.detectSize(); i++) {
      coords = calcGridCoords(d, w, h, r, c);
      if ((coords[0] + d + w) > width) {
        r++;
        c = 0;
        coords = calcGridCoords(d, w, h, r, c);
      }
      if (beat.isOnset(i)) {
        fill(255);
        rect(coords[0], coords[1], coords[2], coords[3]);
      }
      text(i, coords[0] + w/4, coords[1] + h/2);
      c++;
      //println("x1 " + x1 + " d " + d + " w " + w + " width " + width + " " + (x1 + d + w));
    }
    r = 6;
    c = 0;
    coords = calcGridCoords(d, w, h, r, c);
    boolean isKick = beat.isRange(0, 5, 4);
    boolean isSnr = beat.isRange(13, 26, 8);
    boolean isClap = beat.isRange(2, 26, 18);

    coords = calcGridCoords(d, w, h, r, c);
    if (isKick) {
      rect(coords[0], coords[1], coords[2], coords[3]);
    }
    text("isKick", coords[0] + w/4, coords[1] + h/2);

    c++;
    coords = calcGridCoords(d, w, h, r, c);

    if (isSnr) {
      rect(coords[0], coords[1], coords[2], coords[3]);
    }
    text("isSnr", coords[0] + w/4, coords[1] + h/2);

    c++;
    coords = calcGridCoords(d, w, h, r, c);

    if (isClap) {
      rect(coords[0], coords[1], coords[2], coords[3]);
    }
    text("isClap", coords[0] + w/4, coords[1] + h/2);
    
    c++;
    coords = calcGridCoords(d, w, h, r, c);

    if (eBeat.isOnset()) {
      rect(coords[0], coords[1], coords[2], coords[3]);
    }
    text("eBeat", coords[0] + w/4, coords[1] + h/2);
  }
  void drawSpec()
  {
    background(0);

    textSize( 18 );

    float centerFrequency = 0;


    // draw the full spectrum
    {
      noFill();
      for (int i = 0; i < fftLin.specSize(); i++)
      {
        // if the mouse is over the spectrum value we're about to draw
        // set the stroke color to red
        if ( i == mouseX )
        {
          centerFrequency = fftLin.indexToFreq(i);
          stroke(255, 0, 0);
        } else
        {
          stroke(255);
        }
        line(i, height3, i, height3 - fftLin.getBand(i)*spectrumScale);
      }

      fill(255, 128);
      text("Spectrum Center Frequency: " + centerFrequency, 5, height3 - 25);
    }

    // no more outline, we'll be doing filled rectangles from now
    noStroke();

    // draw the linear averages
    {
      // since linear averages group equal numbers of adjacent frequency bands
      // we can simply precalculate how many pixel wide each average's 
      // rectangle should be.
      int w = int( width/fftLin.avgSize() );
      for (int i = 0; i < fftLin.avgSize(); i++)
      {
        // if the mouse is inside the bounds of this average,
        // print the center frequency and fill in the rectangle with red
        if ( mouseX >= i*w && mouseX < i*w + w )
        {
          centerFrequency = fftLin.getAverageCenterFrequency(i);

          fill(255, 128);
          text("Linear Average Center Frequency: " + centerFrequency, 5, height23 - 25);

          fill(255, 0, 0);
        } else
        {
          fill(255);
        }
        // draw a rectangle for each average, multiply the value by spectrumScale so we can see it better
        rect(i*w, height23, i*w + w, height23 - fftLin.getAvg(i)*spectrumScale);
      }
    }

    // draw the logarithmic averages
    {
      // since logarithmically spaced averages are not equally spaced
      // we can't precompute the width for all averages
      for (int i = 0; i < fftLog.avgSize(); i++)
      {
        centerFrequency    = fftLog.getAverageCenterFrequency(i);
        // how wide is this average in Hz?
        float averageWidth = fftLog.getAverageBandWidth(i);   

        // we calculate the lowest and highest frequencies
        // contained in this average using the center frequency
        // and bandwidth of this average.
        float lowFreq  = centerFrequency - averageWidth/2;
        float highFreq = centerFrequency + averageWidth/2;

        // freqToIndex converts a frequency in Hz to a spectrum band index
        // that can be passed to getBand. in this case, we simply use the 
        // index as coordinates for the rectangle we draw to represent
        // the average.
        int xl = (int)fftLog.freqToIndex(lowFreq);
        int xr = (int)fftLog.freqToIndex(highFreq);

        // if the mouse is inside of this average's rectangle
        // print the center frequency and set the fill color to red
        if ( mouseX >= xl && mouseX < xr )
        {
          fill(255, 128);
          text("Logarithmic Average Center Frequency: " + centerFrequency, 5, height - 25);
          fill(255, 0, 0);
        } else
        {
          fill(255);
        }
        // draw a rectangle for each average, multiply the value by spectrumScale so we can see it better
        rect( xl, height, xr, height - fftLog.getAvg(i)*spectrumScale );
      }
    }
  }
}