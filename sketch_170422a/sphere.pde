import spout.*;

// WavesOnSphere_1.0
public class Sphere extends PApplet {
  int Nmax = 1000 ; 
  float M = 50 ; 
  float H = 0.99 ; 
  float HH = 0.01 ;

  float X[] = new float[Nmax+1] ; 
  float Y[] = new float[Nmax+1] ; 
  float Z[] = new float[Nmax+1] ;
  float V[] = new float[Nmax+1] ; 
  float dV[] = new float[Nmax+1] ; 
  float L ; 
  float R = 2*sqrt((4*PI*(200*200)/Nmax)/(2*sqrt(3))) ;
  float Lmin ; 
  int N ; 
  int NN ; 
  float KX ; 
  float KY ; 
  float KZ ; 
  float KV ; 
  float KdV ; 
  int K ;
  int sphereX;
  int sphereY;
  Spout sender;
  String senderName;
  PGraphics pgr; // Graphics for demo
  com.jogamp.newt.opengl.GLWindow window;
  int[][] quadrantBoundaries;

  public Sphere(String sender) {
    senderName = sender;
  }

  void settings() {
    size(700, 600, P3D);
    //  noSmooth() ;
  } // setup()

  void setup() {
    removeExitEvent(getSurface());
    stroke(255, 255, 255) ;
    fill(50, 50, 50) ;
    window = ((com.jogamp.newt.opengl.GLWindow) getSurface().getNative());
    for ( N = 0; N <= Nmax; N++ ) {
      X[N] = random(-300, +300) ;
      Y[N] = random(-300, +300) ;
      Z[N] = random(-300, +300) ;
    }
    quadrantBoundaries = new int[][] {new int[] {0, width/2, height/2, height}, new int[] {width/2, width, height/2, height}, new int[] {0, width/2, 0, height/2}, new int[] {width/2, width, 0, height/2}};
    sphereX = 0;
    sphereY = 0;
    sender = new Spout(this);
    sender.createSender(senderName);
  }

  
  void draw() {
    if (window.hasFocus()) {
      sphereX = mouseX;
      sphereY = mouseY;
    } else if (eBeat.isOnset())
    {
      eRadius = 80;
      int quad = 0;
      for (int i = 0; i < quadrantBoundaries.length; i++) {
        if (sphereX >= quadrantBoundaries[i][0] && sphereX <= quadrantBoundaries[i][1] && sphereY >= quadrantBoundaries[i][2] && sphereY <= quadrantBoundaries[i][3]) {
          quad = i;
          break;
        }
      }
      int newQuad = quad;
      while (newQuad == quad) {
        newQuad = int(random(0, 3));
      }
      sphereX = int(random(quadrantBoundaries[newQuad][0], quadrantBoundaries[newQuad][1]));
      sphereY = int(random(quadrantBoundaries[newQuad][2], quadrantBoundaries[newQuad][3]));
      if (int(random(0, 20)) == 0)
        touch();
    }

    //sphereX = mouseX;
    //sphereY = mouseY;
    background(0, 0, 0) ;

    for ( N = 0; N <= Nmax; N++ ) {
      for ( NN = N+1; NN <= Nmax; NN++ ) {
        L = sqrt(((X[N]-X[NN])*(X[N]-X[NN]))+((Y[N]-Y[NN])*(Y[N]-Y[NN]))) ;
        L = sqrt(((Z[N]-Z[NN])*(Z[N]-Z[NN]))+(L*L)) ;
        if ( L < R ) {
          X[N] = X[N] - ((X[NN]-X[N])*((R-L)/(2*L))) ;
          Y[N] = Y[N] - ((Y[NN]-Y[N])*((R-L)/(2*L))) ;
          Z[N] = Z[N] - ((Z[NN]-Z[N])*((R-L)/(2*L))) ;
          X[NN] = X[NN] + ((X[NN]-X[N])*((R-L)/(2*L))) ;
          Y[NN] = Y[NN] + ((Y[NN]-Y[N])*((R-L)/(2*L))) ;
          Z[NN] = Z[NN] + ((Z[NN]-Z[N])*((R-L)/(2*L))) ;
          dV[N] = dV[N] + ((V[NN]-V[N])/M) ;
          dV[NN] = dV[NN] - ((V[NN]-V[N])/M) ;
          stroke(125+(Z[N]/2), 125+(Z[N]/2), 125+(Z[N]/2)) ; 
          line(X[N]*1.2*(200+V[N])/200+300, Y[N]*1.2*(200+V[N])/200+300, X[NN]*1.2*(200+V[NN])/200+300, Y[NN]*1.2*(200+V[NN])/200+300) ;
        }
        if ( Z[N] > Z[NN] ) {
          KX = X[N] ; 
          KY = Y[N] ; 
          KZ = Z[N] ; 
          KV = V[N] ; 
          KdV = dV[N] ; 
          X[N] = X[NN] ; 
          Y[N] = Y[NN] ; 
          Z[N] = Z[NN] ; 
          V[N] = V[NN] ; 
          dV[N] = dV[NN] ;  
          X[NN] = KX ; 
          Y[NN] = KY ; 
          Z[NN] = KZ ; 
          V[NN] = KV ; 
          dV[NN] = KdV ;
        }
      }
      L = sqrt((X[N]*X[N])+(Y[N]*Y[N])) ;
      L = sqrt((Z[N]*Z[N])+(L*L)) ;
      X[N] = X[N] + (X[N]*(200-L)/(2*L)) ;
      Y[N] = Y[N] + (Y[N]*(200-L)/(2*L)) ;
      Z[N] = Z[N] + (Z[N]*(200-L)/(2*L)) ;
      KZ = Z[N] ; 
      KX = X[N] ;
      //Z[N] = (KZ*cos(float(300-mouseX)/10000))-(KX*sin(float(300-mouseX)/10000)) ;
      //X[N] = (KZ*sin(float(300-mouseX)/10000))+(KX*cos(float(300-mouseX)/10000)) ;
      Z[N] = (KZ*cos(float(300-sphereX)/10000))-(KX*sin(float(300-sphereX)/10000)) ;
      X[N] = (KZ*sin(float(300-sphereX)/10000))+(KX*cos(float(300-sphereX)/10000)) ;
      KZ = Z[N] ; 
      KY = Y[N] ;
      //Z[N] = (KZ*cos(float(300-mouseY)/10000))-(KY*sin(float(300-mouseY)/10000)) ;
      //Y[N] = (KZ*sin(float(300-mouseY)/10000))+(KY*cos(float(300-mouseY)/10000)) ;
      Z[N] = (KZ*cos(float(300-sphereY)/10000))-(KY*sin(float(300-sphereY)/10000)) ;
      Y[N] = (KZ*sin(float(300-sphereY)/10000))+(KY*cos(float(300-sphereY)/10000)) ;
      dV[N] = dV[N] - (V[N]*HH) ; 
      V[N] = V[N] + dV[N] ; 
      dV[N] = dV[N] * H ;
    }
    float a = map(eRadius, 20, 80, 60, 255);
    fill(60, 255, 0, a);
    ellipse(width/2, height/2, eRadius, eRadius);
    eRadius *= 0.95;
    if ( eRadius < 20 ) eRadius = 20;

    if (sender != null) {
      sender.sendTexture();
    }
  } // draw() 

  void setSender(Spout s) {
    sender = s;
  }

  void touch() {

    Lmin = 600 ; 
    NN = 0 ;
    for ( N = 0; N <= Nmax; N++ ) {
      //L = sqrt(((mouseX-(300+X[N]))*(mouseX-(300+X[N])))+((mouseY-(300+Y[N]))*(mouseY-(300+Y[N])))) ;
      L = sqrt(((sphereX-(300+X[N]))*(sphereX-(300+X[N])))+((sphereY-(300+Y[N]))*(sphereY-(300+Y[N])))) ;
      if ( Z[N] > 0 && L < Lmin ) { 
        NN = N ; 
        Lmin = L ;
      }
    }
    if ( K == 0 ) { 
      dV[NN] = -200 ; 
      K = 1 ;
    } else { 
      dV[NN] = +200 ; 
      K = 0 ;
    }
  } // mousePressed()
}