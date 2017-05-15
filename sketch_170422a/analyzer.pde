class BeatListener implements AudioListener
{
  private BeatDetect beat;
  private AudioInput source;

  BeatListener(BeatDetect beat, AudioInput source)
  {
    this.source = source;
    this.source.addListener(this);
    this.beat = beat;
  }

  void samples(float[] samps)
  {
    beat.detect(source.mix);
    fftLin.forward( source.mix );
    fftLog.forward( source.mix );
    eBeat.detect(source.mix);
  }

  void samples(float[] sampsL, float[] sampsR)
  {
    beat.detect(source.mix);
    fftLin.forward( source.mix );
    fftLog.forward( source.mix );
    eBeat.detect(source.mix);
  }
}


class Freq {
  public float power;
  public float freq;
  Freq(float power, float freq) {
    this.power = power;
    this.freq = freq;
  }
  public String toString() {
    return "[" + power + ", " + freq + "]";
  }
}

void analyze() {
  float centerFrequency = 0;

  fftLin2.forward(in.mix );
  fftLog2.forward(in.mix );

  // draw the full spectrum
  //{
  //  for (int i = 0; i < fftLin2.specSize(); i++)
  //  {
  //    // if the mouse is over the spectrum value we're about to draw
  //    // set the stroke color to red
  //    centerFrequency = fftLin2.indexToFreq(i);
  //    line(i, height3, i, height3 - fftLin2.getBand(i)*spectrumScale);
  //  }

  //  text("Spectrum Center Frequency: " + centerFrequency, 5, height3 - 25);
  //}

  linFreqs = new Freq[fftLin2.avgSize()];
  // draw the linear averages
  {
    // since linear averages group equal numbers of adjacent frequency bands
    // we can simply precalculate how many pixel wide each average's 
    // rectangle should be.
    for (int i = 0; i < fftLin2.avgSize(); i++)
    {
      // if the mouse is inside the bounds of this average,
      // print the center frequency and fill in the rectangle with red
      linFreqs[i] = new Freq(fftLin2.getBand(i), fftLin2.indexToFreq(i));
    }
  }
  Arrays.sort(linFreqs, new Comparator<Freq>() {
    public int compare(Freq idx1, Freq idx2) {
      return Float.compare(idx2.power, idx1.power);
    }
  }
  );
  logFreqs = new Freq[fftLog2.avgSize()];

  // draw the logarithmic averages
  {
    // since logarithmically spaced averages are not equally spaced
    // we can't precompute the width for all averages
    for (int i = 0; i < fftLog2.avgSize(); i++)
    {
      logFreqs[i] = new Freq(fftLog2.getAvg(i), fftLog2.getAverageCenterFrequency(i));
    }
  }

  Arrays.sort(logFreqs, new Comparator<Freq>() {
    public int compare(Freq idx1, Freq idx2) {
      return Float.compare(idx2.power, idx1.power);
    }
  }
  );
  eBeat.detect(in.mix);
}

public int freqToMidi(double freq) {
  return 
    (int) java.lang.Math.round (69 +
    (12 *
    java.lang.Math.log ( freq * 0.0022727272727) /
    java.lang.Math.log (2))
    );
}
public double midiToFreq(int note) {
  return 440.0 * java.lang.Math.pow(2.0, (note - 69.0)/ 12.0);
}
public String getNoteName(int note) {
  String[] noteString = new String[] { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" };
  int midi = note % 12;
  return noteString[midi];
}
public int getNoteOctave(int note) {
  return (note / 12) - 1;
}
public double normalizeFreq(double freq) {
  double[] freqs = new double[] {523.251131, 554.365262, 587.329536, 622.253967, 659.255114, 698.456463, 369.994423, 391.995436, 415.304698, 440.000000, 466.163762, 493.883301};
  int midi = freqToMidi(freq);
  int noteIndex = (midi % 12);
  return freqs[noteIndex];
}

public static int[] waveLengthToRGB(double Wavelength, double IntensityMax, double Gamma) {

  double factor;
  double Red, Green, Blue;

  if ((Wavelength >= 380) && (Wavelength<440)) {
    Red = -(Wavelength - 440) / (440 - 380);
    Green = 0.0;
    Blue = 1.0;
  } else if ((Wavelength >= 440) && (Wavelength<490)) {
    Red = 0.0;
    Green = (Wavelength - 440) / (490 - 440);
    Blue = 1.0;
  } else if ((Wavelength >= 490) && (Wavelength<510)) {
    Red = 0.0;
    Green = 1.0;
    Blue = -(Wavelength - 510) / (510 - 490);
  } else if ((Wavelength >= 510) && (Wavelength<580)) {
    Red = (Wavelength - 510) / (580 - 510);
    Green = 1.0;
    Blue = 0.0;
  } else if ((Wavelength >= 580) && (Wavelength<645)) {
    Red = 1.0;
    Green = -(Wavelength - 645) / (645 - 580);
    Blue = 0.0;
  } else if ((Wavelength >= 645) && (Wavelength<781)) {
    Red = 1.0;
    Green = 0.0;
    Blue = 0.0;
  } else {
    Red = 0.0;
    Green = 0.0;
    Blue = 0.0;
  };

  // Let the intensity fall off near the vision limits

  if ((Wavelength >= 380) && (Wavelength<420)) {
    factor = 0.3 + 0.7*(Wavelength - 380) / (420 - 380);
  } else if ((Wavelength >= 420) && (Wavelength<701)) {
    factor = 1.0;
  } else if ((Wavelength >= 701) && (Wavelength<781)) {
    factor = 0.3 + 0.7*(780 - Wavelength) / (780 - 700);
  } else {
    factor = 0.0;
  };


  int[] rgb = new int[3];

  // Don't want 0^x = 1 for x <> 0
  rgb[0] = Red==0.0 ? 0 : (int) Math.round(IntensityMax * Math.pow(Red * factor, Gamma));
  rgb[1] = Green==0.0 ? 0 : (int) Math.round(IntensityMax * Math.pow(Green * factor, Gamma));
  rgb[2] = Blue==0.0 ? 0 : (int) Math.round(IntensityMax * Math.pow(Blue * factor, Gamma));

  return rgb;
}

void draw2()
{
  background(0);

  textSize( 18 );

  float centerFrequency = 0;

  // perform a forward FFT on the samples in jingle's mix buffer
  // note that if jingle were a MONO file, this would be the same as using jingle.left or jingle.right
  //fftLin.forward( in.mix );
  //fftLog.forward( in.mix );

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
    text("Spectrum Center Frequency: " + centerFrequency + " Band " + fftLin.getBand(fftLin.freqToIndex(centerFrequency)), 5, height3 - 25);
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
        text("Linear Average Center Frequency: " + centerFrequency + " Avg " + fftLin.getAvg(i), 5, height23 - 25);

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
        text("Logarithmic Average Center Frequency: " + centerFrequency + " Avg " + fftLog.getAvg(i), 5, height - 25);
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