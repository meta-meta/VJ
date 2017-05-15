// The Nature of Code - Ch.7 Cellular Automata - Daniel Shiffman
// Generative Art - Ch.7 Autonomy - Matt Pearson 
// A 2D cellular automata displayed on a non-rectangular grid.
// two dimensional array, TWO_PI, sin, cos, class, generative, boolean
// Left mouse for next CA, right mouse toggles stroke.

public class CGrid extends PApplet {
  CA2D  ca2d; // generates CA data
  CircularGrid  cg; // displays to monitor
  int index;
  boolean hasStroke;
  com.jogamp.newt.opengl.GLWindow window;
  Spout sender;
  String name;

  public CGrid(String name) {
    this.name = name;
  }

  void settings() {
    size(600, 600, P3D);
  }
  void setup() {
    removeExitEvent(getSurface());
    colorMode(HSB, 255);
    background(0);
    ca2d = new CA2D(140, 30);// col,  row
    cg = new CircularGrid(250, 140, 30); // starting radius, col, row
    hasStroke = false;
    index = 8;
    window = ((com.jogamp.newt.opengl.GLWindow) getSurface().getNative());
    sender = new Spout(this);
    sender.createSender(name);
  }

  void draw() {
    //frameRate(10);
    if (eBeat.isOnset() && int(random(0, 10)) == 0) {
      setIndex();
    }
    background(0);
    ca2d.generate();
    fill(255);
    //textSize(15);
    //text("stroke :", 20, 550);
    //if (hasStroke) text("yes", 80, 550);
    //else text("no", 80, 550);
    //text("selection number :", 20, 570);
    //text(index, 150, 570);
    cg.display();
    noFill();
    stroke(cg.h, 255, 100);
    strokeWeight(2);
    ellipse(0, 0, 120, 120);
    ellipse(0, 0, 540, 540);
    ellipse(0, 0, 40, 40);
    if (sender != null) {
      sender.sendTexture();
    }
  }

  void mousePressed() {
    if (window.hasFocus()) {
      if (mouseButton == LEFT) {
        setIndex();
      }
      if (mouseButton == RIGHT) {
        toggleStroke();
      }
    }
  }
  void setIndex() {
    index  += 1;
    if (index > 18) index = 0;
    ca2d.init();
    cg.h = random(255);
  }
  void toggleStroke() {
    hasStroke = !hasStroke;
  }
  /////////////////////////////////////////////////////////////////

  class CA2D {
    int columns, rows, left, right, up, down;
    float total, average, nextState;
    Cell[][] board;

    CA2D(int c, int r) {
      columns = c ;
      rows = r;
      board = new Cell[columns][rows];
      init();
    }

    void init() {
      for (int i =0; i < columns; i++) {
        for (int j =0; j < rows; j++) {
          board[i][j] = new Cell();
        }
      }
    }

    // calc new state
    void generate() {
      for (int x = 0; x < columns; x++) {
        for (int y = 0; y < rows; y++) {
          total =  average = 0;

          left = x-1;
          right = x+1;
          up = y-1;
          down = y+1;

          // wrap
          if (left < 0) left = 139;
          if (right > 139) right = 0;
          if ( up < 0 ) up = 29;
          if (down > 29) down = 0;

          if (choose[index][0] == 1) total += board[left][up].state;
          if (choose[index][1] == 1)total += board[x][up].state;
          if (choose[index][2] == 1)total += board[right][up].state;

          if (choose[index][3] == 1)total += board[left][y].state;
          if (choose[index][4] == 1) total += board[right][y].state;

          if (choose[index][5] == 1)total += board[left][down].state;
          if (choose[index][6] == 1)total += board[x][down].state; 
          if (choose[index][7] == 1)total += board[right][down].state; 

          average = int(total/8);

          // apply rules
          if (average == 255) board[x][y].newState(0);
          else if (average == 0) board[x][y].newState(255);
          else {
            nextState =  board[x][y].state + average;
            if (board[x][y].previous > 0) nextState -= board[x][y].previous;
            if (board[x][y].previous > 255) nextState = 255;
            else if (nextState < 0 ) nextState = 0;
            board[x][y].savePrevious();
            board[x][y].newState(nextState);
          }
        }
      }
    }
  }
  ///////////////////////////////////////////////////////////////////

  class Cell {
    float state, previous;

    Cell() { 
      state = random(255);
      previous = state;
    }

    void savePrevious() {
      previous = state;
    }

    void newState(float s) {
      state = s;
    }
  }
  /////////////////////////////////////////////////////////////////

  class CircularGrid {
    float rad, incr, off, x, y, sze, reset, h;
    int circs, rings, col, row;

    CircularGrid(float ra, int c, int ri) {
      rad = reset = ra;
      circs = c;
      rings = ri;
      incr = TWO_PI/float(circs);
      off = incr/2;
      h = random(255);
    }

    void display() {
      h += .5;
      if (h > 255) h = 0;
      rad = reset;
      translate(width/2, height/2);
      for ( row = 0; row< rings; row++) {
        drawCircles();
        rad = rad - (rad/24);
        if (off ==  incr/2) off = 0;
        else off = incr/2;
      }
    }

    void drawCircles() {
      col = -1;
      for (float i = 0-off; i < TWO_PI-off; i += incr) {
        x = rad * cos(i);
        y = rad * sin(i);
        sze = (2 * rad * PI)/circs;
        col++;
        if (hasStroke) {
          stroke(h, 255, 255);
          strokeWeight(.5);
        } else  noStroke();
        fill(h, ca2d.board[col][row].state, (ca2d.board[col][row].state) * .75);
        ellipse(x, y, sze, sze);
      }
    }
  }
  //////////////////////////////////////////////////////////////////////

  int choose[][] =
    {
    {
      0, 1, 1, 1, 1, 1, 1, 1, //0
    }
    , 
    {
      1, 0, 1, 1, 1, 1, 1, 1, 
    }
    , 
    {
      1, 1, 0, 1, 1, 1, 1, 1, 
    }
    , 
    {
      1, 1, 1, 0, 1, 1, 1, 1, 
    }
    , 
    {
      1, 1, 1, 1, 0, 1, 1, 1, 
    }
    , 
    {
      1, 1, 1, 1, 1, 0, 1, 1, 
    }
    , 
    {
      1, 1, 1, 1, 1, 1, 0, 1, 
    }
    , 
    {
      1, 1, 1, 1, 1, 1, 1, 0, 
    }
    , 
    {
      1, 1, 1, 1, 1, 1, 1, 1, //8
    }
    , 
    {
      0, 0, 1, 1, 1, 1, 1, 1, 
    }
    , 
    {
      1, 0, 0, 1, 1, 1, 1, 1, 
    }
    , 
    {
      1, 1, 1, 1, 1, 1, 0, 0, 
    }
    , 
    {
      1, 1, 1, 1, 1, 0, 0, 1, //12
    }
    , 
    {
      1, 1, 1, 0, 1, 1, 0, 1, 
    }
    , 
    {
      0, 1, 0, 1, 1, 1, 1, 1, 
    }
    , 
    {
      1, 1, 0, 0, 1, 1, 1, 1, 
    }
    , 
    {
      0, 1, 1, 0, 1, 1, 1, 1, 
    }
    , 
    {
      1, 1, 1, 1, 1, 0, 1, 0, 
    }
    , 
    {
      0, 0, 0, 0, 1, 0, 0, 0, //18
    }
    , 
  };
}