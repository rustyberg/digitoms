import java.util.*;
import processing.pdf.*;
import java.io.*;
import javax.swing.JOptionPane;
import javax.swing.JFileChooser;

/*
 * Control digitom drawing:
 * General:
 * <space> - stop/start
 * b/B - Background color -/+
 * c/C - Capture image png/PDF
 * e/E - Decrease/increase error%
 * i   - Info display on/off
 * m   - cycle modes: shapes, spiro, curves, all
 * r   - New random settings
 * z/Z - Zoom in/out
 * Color
 * h/H - hue -/+
 * (/) - hue range -/+
 * s/S - saturation -/+
 * {/} - saturation range -/+
 * v/V - value (brightness) -/+
 * [/] - Value (brightness) range -/+
 * o/O - Opacity (alpha) -/+
 * </> - Opacity (alpha) range -/+
 * l/L - line weight -/+
 * Shapes:
 * f   - fill on/off
 * 1   - elipse on/off
 * 2   - triangles on/off
 * 3   - quads on/off
 * 4   - rects on/off
 * 5   - stars on/off
 * 6   - Petals on/off
 * 7   - Flowers on/off
 * 8   - Hearts on/off
 * -/+ - # of shapes
 * Spiro:
 * w/W - Wheel 1 radius
 * d/D - Wheel 2 radius
 * p/P - pen position within wheel 2
 * -/+ - Angle per step
 * Curves:
 * -/+ - # lines
 *
 */

 // Default screen size
static int di_Size = 1000;  // default size of square screen
static int Max_x = di_Size;
static int Max_y = di_Size;
static final int di_MAXFAMS = 64;   // Max number of families
static final int di_MAXDIGS = 32;  // Max number of digitoms on map


// Display and control
color di_Background = color(0, 0, 0);
boolean di_Info = true;    // display info lines
float di_Zoom = 1.0;
static final int di_INCR = 5;

// Rotation angle for static digitom
float di_Angle = 0.0;

// Movement within the families and digitims map
diMove di_Movement = diMove.MOVE_NONE;

// Info for tracking array of created families
int di_NextFam = 0; // Index for next open slot in the family array
int di_CurrentFam = 0;  // Currently displayed family
diFamily[] di_Families = new diFamily[di_MAXFAMS];   // families array
diFamily F;        // the current family
diFamily Fprev;    // the previous family

// Array of seeds to allow forward and back movement within a family
int di_NextSeed = 0;
int di_CurrentSeed = 0;
int[] di_Seeds = new int[di_MAXDIGS];
int di_Seed;

// Something has changed since last draw
boolean di_Change = true;

// Capture current image as PDF
boolean di_PDF = false;

// used to generate the random starting point values, NOT DIGITOM VALUES
// because the seed is different!
Random R = new Random();

// The drawing frame
PGraphics di_Frame;  // Graphics frame so we can get transparent background
int di_FrameX;

// comand and info display frame
PGraphics di_Cmd;  // commands window
int di_CmdWidth;
int di_CmdHeight;
int di_CmdX;

// Map of active digitoms
// Implements 2 Pimages: the backing map (large) and the map view (small)
// digitim icons are drawn to the map and then a portion is copied to the view for display
static final int di_MAPPIX = 32;  // Size in pixels of the map icon image
static final int di_MapWidth = di_MAXFAMS * di_MAPPIX;  // Width of the map
static final int di_MapHeight = di_MAXDIGS * di_MAPPIX; // Height of map
PGraphics di_Map;
int di_MapX;      // Where to plop it in the drawing frame
PImage di_MapView;
int di_MapViewWidth;  // Width of the map view window
int di_MapViewHeight;  // Height of the window onto the map
int di_MapViewX;  // Left edge of window into map
int di_MapViewY;  // Top edge of window into map

// Directory names where various stuff gets saved
File di_DocsDir;  // the ~/Documents directory
File di_DigiData;  // The ~/Documents/DigiData folder
static final String DI_DIGIDATA = "DigiData";
File di_DataDir;  // The processing sketch data directory

private void prepareExitHandler () {
  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
    public void run () {
      save_family(F);    // give the user a chance to save if necessary
    }
  }));

}

boolean sketchFullScreen() {
  return true;
}

void setup() {
  PFont hlv = loadFont("Courier-12.vlw");
  String lines[] = loadStrings("controls.txt");
  String docs;
  String sep = System.getProperty("file.separator");
  
  // Do some yucky stuff to get the correct file path for the digidata folder
  if (System.getProperty("os.name").startsWith("Win")) {
    docs = new JFileChooser().getFileSystemView().getDefaultDirectory().toString();
  } else {
    docs = System.getProperty("user.home") + sep + "Documents";
  }
  di_DocsDir = new File(docs);
  di_DigiData = new File(di_DocsDir, DI_DIGIDATA);
  
  // Make sure the data directory exists and is writable
  if (di_DigiData.exists()) {
    if (!di_DigiData.isDirectory() || !di_DigiData.canWrite()) {
      println("can't write to data folder: " + di_DigiData);
      exit();
    }
  } else if (!di_DigiData.mkdir()) {
    println("Can't create data folder: " + di_DigiData);
    exit();
  }
  
  // We don't check the existance of the data dir because processing does it for us
  File di_DataDir = new File(dataPath(""));
  
  prepareExitHandler();
  di_Size = min(displayWidth, displayHeight);
  Max_x = Max_y = di_Size;
//  size(di_Size, di_Size);
  size(displayWidth, displayHeight);  // Whole screen
    
  // create a frame for the digimap and fill it with gray 
  di_MapViewWidth = (displayWidth - di_Size) / 2;
  di_MapViewHeight = displayHeight;
  di_MapViewX = 0;
  di_MapViewY = 0;
  di_MapView = new PImage(di_MapViewWidth, di_MapViewHeight);
  di_Map = createGraphics(di_MapWidth, di_MapHeight);
  di_Map.beginDraw();
  di_Map.background(128);
  di_Map.endDraw();
  di_MapX = 0;
  
  // Actual drawing frame for the digitoms
  di_Frame = createGraphics(di_Size, di_Size); 
  di_FrameX = di_MapViewWidth;

  // create a frame for the command strings and fill it in
  di_CmdWidth = (displayWidth - di_Size) / 2;
  di_CmdHeight = displayHeight;
  di_CmdX = displayWidth - di_CmdWidth;
  di_Cmd = createGraphics(di_CmdWidth, di_CmdHeight);
  di_Cmd.beginDraw();
  di_Cmd.background(128);
  di_Cmd.textFont(hlv, 12);
  di_Cmd.fill(255);
  for (int i = 0; i < lines.length && (i+1)*12 < di_CmdHeight; i++) {
    di_Cmd.text(lines[i], 0, (i+1)*12);
  }
  di_Cmd.endDraw();

  smooth();
  noFill();
  colorMode(HSB);
  rectMode(CENTER);
  hint(ENABLE_STROKE_PURE);   
  
  // Fill in the first seed entry and set current and next
  di_CurrentSeed = 0;
  di_NextSeed = 1;
  di_Seed = di_Seeds[di_CurrentSeed] = round(random(Integer.MAX_VALUE-1));
  
  // Fill in the first family entry with the default family
  di_Movement = diMove.MOVE_NONE;
  di_CurrentFam = 0;
  di_NextFam = 0;
  load_families(di_DataDir, true);  // first load the standard families read-only
  load_families(di_DigiData, false);  // now load the user's families read-write
  if (di_NextFam >= di_Families.length) {
    println("Too many families!");
  } else {
    di_Families[di_NextFam++] = new diFamily();
  }
  di_CurrentFam = di_NextFam - 1;
  Fprev = F = di_Families[di_CurrentFam];
  di_MapViewX = di_CurrentFam * di_MAPPIX;
  di_MapViewX = min(di_MapViewX, di_MapWidth - di_MapViewWidth);
  di_MapViewY = 0;
}

float di_RotAngle = 0.0;
color color_start, color_end;

void draw() { 
  PGraphics old_frame = di_Frame;
  
  if (di_PDF) {
    // user requested a snap of current pict, redraw it to file
    
    old_frame = di_Frame;
    File fname = new File(di_DigiData, datename("digitom", ".pdf"));
    di_Frame = createGraphics(Max_x, Max_y, PDF, fname.toString());
    beginRecord((PGraphicsPDF)di_Frame);
  } else {
    // Normal renderer,
    
    /*
     * Check if we need a new family because a read-only family was changed
     * If array is full pop up a message and undo changes
     */
    if (F.f_Readonly && F.f_Modified) {
      if (di_NextFam >= di_Families.length) {
        JOptionPane.showMessageDialog(null, "Too many families!");
        F = di_Families[di_CurrentFam] = reload_family(F.f_Name);
        di_Change = true;
      } else {
        // create a new family that is a dup of the current one and put
        // current back to its unmodified form
        String fname = new String(System.getProperty("user.name") + "-" + di_NextFam);
        Fprev = di_Families[di_CurrentFam] = reload_family(F.f_Name);
        di_CurrentFam = di_NextFam;
        di_NextFam++;
        F = di_Families[di_CurrentFam] = new diFamily(F, fname);
      }
    }
    
    // Check for movement
    if (di_Movement == diMove.MOVE_UP) {
      di_Movement = diMove.MOVE_NONE;
      if (--di_CurrentSeed < 0) {
        di_CurrentSeed = 0;
      } else {
        di_Seed = di_Seeds[di_CurrentSeed];
      }
    } else if (di_Movement == diMove.MOVE_DOWN) {
      di_Movement = diMove.MOVE_NONE;
      if (++di_CurrentSeed < di_NextSeed) {
        di_Seed = di_Seeds[di_CurrentSeed];
      } else {
        // New digitom within a family, create new seed if there is room
        if (di_NextSeed < di_Seeds.length) {
          di_Seed = round(random(Integer.MAX_VALUE-1));
          di_NextSeed++;
          di_Seeds[di_CurrentSeed] = di_Seed;
        } else {
          di_CurrentSeed = di_NextSeed - 1;
          di_Seed = di_Seeds[di_CurrentSeed];
        }
      } 
    } else if (di_Movement == diMove.MOVE_LEFT) {
      di_Movement = diMove.MOVE_NONE;
      // Move left one family flush changes to current family
      
      // Save current family if modified
      if (F.f_Modified && !save_family(F)) {
        // User decided not to save changes, reload the family
        F = di_Families[di_CurrentFam] = reload_family(F.f_Name);
        if (F == null) {
          // New family not saved back everything up, return to first seed
          F = Fprev;
          di_NextFam--;
          di_mapclear_fam(di_CurrentFam);
          di_CurrentSeed = 0;
          di_Seed = di_Seeds[di_CurrentSeed];
        }
      }
      if (di_CurrentFam != 0) {
        di_CurrentFam--;
        Fprev = F;
        F = di_Families[di_CurrentFam];
      }
      // Keep current seed
      assert (di_Seed == di_Seeds[di_CurrentSeed]);
    } else if (di_Movement == diMove.MOVE_RIGHT) {
      di_Movement = diMove.MOVE_NONE;
      // Move right one family if not already at the end
      
      // Save current family if modified
      if (F.f_Modified && !save_family(F)) {
        // User decided not to save changes, reload the family
        F = di_Families[di_CurrentFam] = reload_family(F.f_Name);
        if (F == null) {
          // Family does not exist, back everything up, reset to first seed
          di_mapclear_fam(di_CurrentFam);
          di_CurrentFam--;
          di_NextFam--;
          F = di_Families[di_CurrentFam];
          di_CurrentSeed = 0;
          di_Seed = di_Seeds[di_CurrentSeed];
        }
        // *** should clean up family on map!
      }
      if (di_CurrentFam != (di_Families.length - 1)) {

        di_CurrentFam++;    // Next family
        if (di_CurrentFam == di_NextFam) {
          // create new random family
          String fname = new String(System.getProperty("user.name") + "-" + di_NextFam);
          Fprev = F;
          F = di_Families[di_CurrentFam] = new diFamily(fname);
          di_NextFam++;
        } else {
          // Just update the current and prev pointers
          Fprev = F;
          F = di_Families[di_CurrentFam];
        }
        // Keep current seed
        assert (di_Seed == di_Seeds[di_CurrentSeed]);
      }   
    } else {
      // No movement, just rotate existing
      di_RotAngle += 0.04;
    }
  } 
  
  if (di_Change || di_PDF) {
    // Something in the parameters has changed, redraw the frame
    randomSeed(di_Seed);
    di_Frame.beginDraw();
    di_Frame.smooth();
    di_Frame.noFill();
    di_Frame.translate(Max_x/2, Max_y/2);
    di_Frame.colorMode(HSB);
    di_Frame.rectMode(CENTER);
    di_Frame.hint(ENABLE_STROKE_PURE);
    di_Frame.scale(di_Zoom);
    if (di_PDF) {
      di_Frame.background(di_Background);  // can't use transparent with PDF!
    } else {  
      di_Frame.background(di_Background, 0);  // frame backgound transparent
    }
    
    // pick random start and end colors
    color_start = color(F.f_HueLow, F.f_SatLow, F.f_ValLow, F.f_AlphaLow);
    color_end = color(F.f_HueHigh, F.f_SatHigh, F.f_ValHigh, F.f_AlphaHigh);
    
    di_Frame.strokeWeight(F.f_LineWeight);
    
    if (F.f_Mode == diMode.SHAPES) {
      draw_shapes(di_Seed, Max_x, Max_y, color_start, color_end);
    } else if (F.f_Mode == diMode.CURVES) {
      draw_curves(di_Seed, Max_x, Max_y, color_start, color_end);
    } else if (F.f_Mode == diMode.SPIRO) {
      draw_spiro(di_Seed, Max_x, Max_y, color_start, color_end);
    } else {
//      di_Frame.blendMode(BLEND);
      
      // turn down alpha for lines
      color dim_start = color(hue(color_start), saturation(color_start), brightness(color_start), alpha(color_start) * 0.3);
      color dim_end = color(hue(color_end), saturation(color_end), brightness(color_end), alpha(color_end) * 0.3);
      
      draw_spiro(di_Seed, Max_x, Max_y, dim_start, dim_end);
      draw_curves(di_Seed, Max_x, Max_y, dim_start, dim_end);
      draw_shapes(di_Seed, Max_x, Max_y, color_start, color_end);
      
//      di_Frame.blendMode(BLEND);
    } 
    di_Frame.endDraw();
    // Draw a mappixXmappix icon onto the map at (seedpos, fampos)
    if (!di_PDF) {
      di_mapdraw(di_CurrentFam, di_CurrentSeed);  
    }  
  } // end of draw new frame

   
  if (di_PDF) {
    di_PDF = false;
    // print_info(di_Frame);
    endRecord();
    di_Frame = old_frame;
  } else {   
    colorMode(HSB);
    background(di_Background);
    pushMatrix();   
    resetMatrix();    
    translate(displayWidth/2, displayHeight/2);
    rotate((TWO_PI / 360) * di_RotAngle);
    translate(-displayWidth/2, -displayHeight/2);
    image(di_Frame, di_FrameX, 0);  
    popMatrix(); 
    if (di_Info) {
      print_info(g);
      image(di_Cmd, di_CmdX, 0);
      di_MapView.copy(di_Map, di_MapViewX, di_MapViewY, di_MapViewWidth, di_MapViewHeight,
                          0, 0, di_MapViewWidth, di_MapViewHeight);
      image(di_MapView, di_MapX, 0);
    }  
  } 

  di_Change = false;
}

// Create a random point within the circle with center (0,0) and given radius
class RandPoint {
  float x, y;  // Random x,y

  // Constructor
  RandPoint(float radius) {
    float theta = random(0, TWO_PI);
    float r = random(0, radius);
    
    x = r*cos(theta);
    y = r*sin(theta);
  }
}

// create a randomly place box within the area of a circle centered on 0,0
// with the given radius
class RandBox {
  float cx, cy;  // box center
  float w, h;    // width and height
  
  // Constructor
  RandBox(float radius) {
    float theta = random(0, TWO_PI);
    float r = random(-0.1 * radius, 0.8 * radius);
    
    float x1 = r*cos(theta);
    float y1 = r*sin(theta);
    r = random(0.1 * radius, 0.8 * radius);
    float x2 = r*cos(theta);
    float y2 = r*sin(theta);
          
    cx = x1 + (x2 - x1) / 2.0;
    cy =y1 + (y2 - y1) / 2.0;
    w = abs(x2 - x1);
    h = abs(y2 - y1);
    if ((cx + w/2) > radius ||
        (cx - w/2) < -radius ||
        (cy + h/2) > radius ||
        (cy - h/2) < -radius) {
    }  
  }
}

color di_lerpColor(int first, int last, float offset) {
  color out;
  int h_first = round(hue(first));
  int h_last = round(hue(last));
  int h_range = h_last - h_first;
  float new_hue;
  
  if (h_range < 1) {
    new_hue = hue(first) + (255 + h_range) * offset;
  } else {
    new_hue = hue(first) + h_range * offset;
  }
  
  new_hue %= 256;
  out = lerpColor(first, last, offset);
  return (color(new_hue, saturation(out), brightness(out), alpha(out)));
}  

void draw_curves(int seed, int max_x, int max_y, int color_start, int color_end) {
  RandPoint p1, p2, c1, c2;        // bezier 1 points
  RandPoint p3, p4, c3, c4;        // bezier 2 points
  int lines;                       // tween lines
  int rot;                         // rotation count
  float color_step;

  float p1x, p1y, c1x, c1y, p2x, p2y, c2x, c2y;
  float p1_xstep, p1_ystep, p2_xstep, p2_ystep;
  float c1_xstep, c1_ystep, c2_xstep, c2_ystep; 
  
  randomSeed(seed);
  
  lines = F.f_Nlines;  // tween lines
  rot = F.f_Nrot;      // Rotation count
  
  // create bezier points
  p1 = new RandPoint(di_Size/3.0);
  p2 = new RandPoint(di_Size/3.0);
  c1 = new RandPoint(di_Size/2.0);
  c2 = new RandPoint(di_Size/2.0);
  p3 = new RandPoint(di_Size/3.0);
  p4 = new RandPoint(di_Size/3.0);
  c3 = new RandPoint(di_Size/2.0);
  c4 = new RandPoint(di_Size/2.0);
   
 
  // Calculate steps between bezier points
  p1_xstep = (p2.x - p1.x) / (float)lines;
  p1_ystep = (p2.y - p1.y) / (float)lines;
  p2_xstep = (p4.x - p3.x) / (float)lines;
  p2_ystep = (p4.y - p3.y) / (float)lines;
  c1_xstep = (c2.x - c1.x) / (float)lines;
  c1_ystep = (c2.y - c1.y) / (float)lines;
  c2_xstep = (c4.x - c3.x) / (float)lines;
  c2_ystep = (c4.y - c3.y) / (float)lines;
     
  di_Frame.strokeWeight(F.f_LineWeight/2);

  // draw the lines then rotate and do it again
  di_Frame.pushMatrix();
  for (int j = 0; j < rot; j++) {
    p1x = p1.x;
    p1y = p1.y;
    c1x = c1.x;
    c1y = c1.y;
    p2x = p2.x;
    p2y = p2.y;
    c2x = c2.x;
    c2y = c2.y;
    for (int i = 0; i < lines; i++) {
      di_Frame.stroke(di_lerpColor(color_start, color_end, (float)i/(float)lines));
      di_Frame.bezier(p1x, p1y, c1x, c1y, c2x, c2y, p2x, p2y);
      p1x += addnoise(p1_xstep, max_x/2);
      p1y += addnoise(p1_ystep, max_y/2);
      c1x += c1_xstep;
      c1y += c1_ystep;
      p2x += addnoise(p2_xstep, max_x/2);
      p2y += addnoise(p2_ystep, max_y/2);
      c2x += c2_xstep;
      c2y += c2_ystep;
    }
    di_Frame.rotate(addnoise(TWO_PI / rot, TWO_PI / rot));
  }
    
  di_Frame.strokeWeight(F.f_LineWeight);
  di_Frame.popMatrix();
}


void draw_shapes(int seed, int max_x, int max_y, int color_start, int color_end) {
  float cx, cy, h, w;               // center, height, width of shape
  diShape[] s = new diShape[F.f_Nshapes];

  // check for special case: nothing to draw!
  if (F.f_Nshapes == 0 ||
      !(F.f_Elipse || F.f_Quad || F.f_Rect || F.f_Star || F.f_Tri || F.f_Petal || F.f_Flower || F.f_Heart) ){
    return;
  }

  // set randomSeed so outcome is repeatable
  randomSeed(seed);
  
  // Fill the shapes array
  float radius = min(max_x, max_y) / 2.0;
  for (int i = 0; i < F.f_Nshapes; i++) { 
      RandBox b = new RandBox(radius);
      s[i] = NewShape(b.cx, b.cy, b.w, b.h);
  }  

  float line_alpha = random(F.f_Alpha, F.f_AlphaHigh);
  float fill_alpha = random(F.f_AlphaLow, F.f_AlphaHigh);

  for (int j = 0; j <  F.f_Nrot; j++) {
    di_Frame.pushMatrix();
    for (int i = 0; i < F.f_Nshapes; i++) {
      int cur_color = di_lerpColor(color_start, color_end, (float)i/(float)F.f_Nshapes);
      di_Frame.stroke(cur_color, line_alpha);
      if (F.f_Fill) {
        di_Frame.fill(cur_color, alpha(cur_color));
      } else {
        di_Frame.noFill();
      }
      s[i].AddNoise(F.f_Error);
      s[i].Display(di_Frame);
    }
    di_Frame.popMatrix();
    di_Frame.rotate(addnoise(TWO_PI / F.f_Nrot, PI));
  }
}

float addnoise(float inval, float range) {
  if (F.f_Error == 0.0) return(inval);
  
  float err = F.gaussian(0.5, 0.5, 0, 01.0) - 0.5;
  return (inval + (range * err * F.f_Error / 100.0));
}

void noiseStart(int seed) {
  noiseSeed(seed);
}
  
int di_LastSpiroSeed = 0;
float r1 = 0.0;
float r2 = 0.0;
float rpen = 0.0;    // radius of pen point in wheel 2

void draw_spiro(int seed, int max_x, int max_y, int color_start, int color_end) {

  float theta = F.f_Nrot * F.f_SpiroDensity * TWO_PI;
  float cur_theta;
  float cx;      // center of drawing area
  float cy;
  float c1x;    // center of wheel 1
  float c1y;
  float c2x;    // center of wheel 2
  float c2y;
  float px;     // pen position
  float py;
  float theta2 = 0.0;  // rotation of wheel 2
  float incr;
  float last_px, last_py;
  int cur_color;

  randomSeed(seed);
  di_Frame.strokeJoin(MITER);
  di_Frame.strokeCap(SQUARE);
  di_Frame.strokeWeight(F.f_LineWeight/2);
  
  // If this is a new seed or params have changed randomize parameters
  if (di_Change || seed != di_LastSpiroSeed || di_LastSpiroSeed == 0) {
    di_LastSpiroSeed = seed;
    r1 = di_Size*F.f_R1/200;
    r1 -= random(0.1) * r1;
    r2 = r1 * F.f_R2/100;
    r2 -= random(0.2) * r2;
    rpen = r2 * F.f_Rpen/100;
    rpen -= random(0.2) * rpen;
  }
  incr = radians(F.f_Step); // theta increment per iteration
  
  cx = 0;
  cy = 0;
  
  // center of wheel 1 is center of drawing area
  c1x = cx;
  c1y = cy;
  
  
  // center of wheel 2 is inside wheel 1 on the theta = 0.0 line
  c2x = c1x + (r1 - r2);
  c2y = c1y;
  
  // set initial pen position: px,py for theta = 0.0 and theta2 = 0.0
  px = c2x + rpen;
  py = c2y;
  
  last_px = px;
  last_py = py;
  cur_color = color_start;
//  cur_color = color(hue(cur_color), saturation(cur_color), brightness(cur_color), 128);
  for (cur_theta = incr; cur_theta < theta; cur_theta += incr) {
    // set theta2 c2x, c2y, and px, py for current rotation
    c2x = c1x + (r1 - r2) * cos(cur_theta);
    c2y = c1y + (r1 - r2) * sin(cur_theta);
    theta2 = -cur_theta * (r1/r2);
    px = c2x + rpen * cos(theta2);
    py = c2y + rpen * sin(theta2);
    
    px = addnoise(px, max_x/2);
    py = addnoise(py, max_y/2);
    
    di_Frame.stroke(cur_color);
    di_Frame.line(last_px, last_py, px, py);
    last_px = px;
    last_py = py;
    cur_color = di_lerpColor(color_start, color_end, (sin(theta2/1.7)+1.0)/2.0);
//    cur_color = color(hue(cur_color), saturation(cur_color), brightness(cur_color), 128);
  }
    
  di_Frame.strokeWeight(F.f_LineWeight);
}

static int mapLastX = -1;
static int mapLastY = -1;

// draw a digimap entry at x,y
void di_mapdraw(int x, int y) {
  di_Map.beginDraw();
  di_Map.strokeWeight(1);
  if (mapLastX != x || mapLastY != y) {
    // active changed move view window if necessary
    int pixelX = x * di_MAPPIX;
    int pixelY = y * di_MAPPIX;
    if (pixelX < di_MapViewX) {
      // moved off left edge, reset left edge
      di_MapViewX = pixelX;
    } else if ((pixelX + di_MAPPIX) >= (di_MapViewX + di_MapViewWidth)) {
      // moved off right edge, shift so right side of icon is in the window
      di_MapViewX = pixelX + di_MAPPIX - di_MapViewWidth;
    }
    if (pixelY < di_MapViewY) {
      // moved off top edge, reset top edge
      di_MapViewY = pixelY;
    } else if ((pixelY + di_MAPPIX) >= (di_MapViewY + di_MapViewHeight)) {
      // moved off bottom edge, shift bottom side of icon is in the window
      di_MapViewY = pixelY + di_MAPPIX - di_MapViewHeight;
    }
    // active changed, remove box on previous
    di_Map.stroke(128);
    di_Map.noFill();
    di_Map.rect(di_MAPPIX*mapLastX, di_MAPPIX*mapLastY,
                di_MAPPIX, di_MAPPIX);
    mapLastX = x;
    mapLastY = y;
  }  
  di_Map.stroke(255, 0, 0);
  di_Map.fill(128);
  di_Map.rect(di_MAPPIX*x, di_MAPPIX*y, di_MAPPIX, di_MAPPIX);
  di_Map.noFill();            
  di_Map.image(di_Frame,
               di_MAPPIX*x+1, di_MAPPIX*y+1, di_MAPPIX-2, di_MAPPIX-2);
  di_Frame.endDraw();             
  di_Map.endDraw(); 
}

// clear a digimap entry at x,y
void di_mapclear(int x, int y) {
  di_Map.beginDraw();
  di_Map.strokeWeight(1);
  di_Map.stroke(128);
  di_Map.fill(128);
  di_Map.rect(di_MAPPIX*x, di_MAPPIX*y, di_MAPPIX, di_MAPPIX);
  di_Map.noFill();            
  di_Map.endDraw(); 
}

// Clear out a family column
void di_mapclear_fam(int fam) {
  di_Map.beginDraw();
  di_Map.strokeWeight(1);
  di_Map.stroke(128);
  di_Map.fill(128);
  di_Map.rect(di_MAPPIX*fam, 0, di_MAPPIX, di_MAPPIX * di_MapHeight);
  di_Map.noFill();            
  di_Map.endDraw(); 
}

void print_info(PGraphics pg) {
  String s1, s2;
  int fill = pg.brightness(di_Background) < 128 ? 255 : 0;
 
  if (!di_Info) {
    return;
  }
  
  // pg.colorMode(RGB);     
  pg.textSize(12);
  g.textAlign(RIGHT);
  if (F.f_Readonly) {
    pg.fill(0, 255, 255, 255);    // red
  } else {
    pg.fill(76, 255, 255, 255);    // green
  }
  g.text(F.f_Name, di_CmdX, 1*12);
  pg.fill(fill);
  g.text(hex(di_Seed), di_CmdX, 7*12);
  g.text(F.f_Nrot, di_CmdX, 8*12);
  g.text(hex(di_Background), di_CmdX, 9*12);
  g.text(F.f_Error, di_CmdX, 11*12);
  g.text(F.f_LineWeight, di_CmdX, 13*12);
  g.text(F.f_Mode.name(), di_CmdX, 14*12);
  g.text(pctstr(di_Zoom, 1), di_CmdX, 16*12);
  g.text(F.f_Hue, di_CmdX, 19*12);
  g.text(pctstr(F.f_HueRange, 255), di_CmdX, 20*12);
  g.text(F.f_Sat, di_CmdX, 21*12);
  g.text(pctstr(F.f_SatRange, 255), di_CmdX, 22*12);
  g.text(F.f_Val, di_CmdX, 23*12);
  g.text(pctstr(F.f_ValRange, 255), di_CmdX, 24*12);
  g.text(F.f_Alpha, di_CmdX, 25*12);
  g.text(pctstr(F.f_AlphaRange, 255), di_CmdX, 26*12);
  g.text(F.f_Nlines, di_CmdX, 29*12);
  g.text(F.f_Nshapes, di_CmdX, 32*12);
  g.text(F.f_Fill ? "On" : "Off", di_CmdX, 33*12);
  g.text(F.f_Elipse ? "On" : "Off", di_CmdX, 34*12);
  g.text(F.f_Tri ? "On" : "Off", di_CmdX, 35*12);
  g.text(F.f_Quad ? "On" : "Off", di_CmdX, 36*12);
  g.text(F.f_Rect ? "On" : "Off", di_CmdX, 37*12);
  g.text(F.f_Star ? "On" : "Off", di_CmdX, 38*12);
  g.text(F.f_Petal ? "On" : "Off", di_CmdX, 39*12);
  g.text(F.f_Flower ? "On" : "Off", di_CmdX, 40*12);
  g.text(F.f_Heart ? "On" : "Off", di_CmdX, 41*12);
  g.text(F.f_SpiroDensity, di_CmdX, 44*12);
  g.text(F.f_Step, di_CmdX, 45*12);
  g.text(F.f_R2 + "%", di_CmdX, 46*12);
  g.text(F.f_Rpen + "%", di_CmdX, 47*12);
  g.text(F.f_R1 + "%", di_CmdX, 48*12);
  g.text(round(hue(color_start)), di_CmdX, 54*12);
  g.text(round(saturation(color_start)), di_CmdX, 55*12);
  g.text(round(brightness(color_start)), di_CmdX, 56*12);
  g.text(round(alpha(color_start)), di_CmdX, 57*12);
  g.text(round(hue(color_end)), di_CmdX, 60*12);
  g.text(round(saturation(color_end)), di_CmdX, 61*12);
  g.text(round(brightness(color_end)), di_CmdX, 62*12);
  g.text(round(alpha(color_end)), di_CmdX, 63*12);
}

String pctstr(float val, float max) {
  return (round(100.0 * val / max) + "%");
}  

void keyPressed() {
  
  di_Change = true;
  
  // next/prev family and digitom use arrow keys
  if (key == CODED) {
    if (keyCode == UP) {
      di_Movement = diMove.MOVE_UP;
    } else if (keyCode == DOWN) {
      di_Movement = diMove.MOVE_DOWN;
    } else if (keyCode == LEFT) {
      di_Movement = diMove.MOVE_LEFT;
    } else if (keyCode == RIGHT) {
      di_Movement = diMove.MOVE_RIGHT;
    }
    return;
  } else {
    di_Movement = diMove.MOVE_NONE;
  }
  
  // In case we will be setting background below
  float h = hue(di_Background);
  float b = brightness(di_Background);
  
  // General controls
  switch (key) {
    case 'Q':
      stop();
      exit();
      break; 

    // Next digitom
    case ' ':
      di_Movement = diMove.MOVE_DOWN;  
      break;

    // Capture frame 'c' == file.png, 'C' == file.PDF
    case 'c':
      // Save in the user's digidata dir
      File fname = new File(di_DigiData, datename("digitom", ".png"));
      di_Frame.save(fname.toString());
      break;
      
    case 'C':
      di_PDF = true;
      break;

    // Turn info display on/off
    case 'i':
      di_Info = !di_Info;
      break;
  
    // Set background brightness: 0-- == 255, 255++ == 0, otherwise increase/decrease grey
    case 'b':
      b -= di_INCR;
      if (b < 0) b = 255;
      di_Background = color(hue(di_Background), 0.0, b);
      break;
    case 'B': 
      b += di_INCR;
      if (b > 255) b = 0;
      di_Background = color(hue(di_Background), 0.0, b);
      break;
    
    // Set background hue: 0-- == 255, 255++ == 0, otherwise increase/decrease grey
    case 'n':
      h -= di_INCR;
      if (h < 0) h = 255 - di_INCR; // BUG workaround - using 255 rounds to 0!
      if (b == 0) b = di_INCR;    // no color if black
      if (b == 255) b = 255 - di_INCR; // BUG can't change hue if brightness is 255
      di_Background = color(h, 100.0, b);
      break;
    
    case 'N':
      h += di_INCR;
      if (h > 255) h = 0;
      if (b == 0) b = di_INCR;    // no color if black
      if (b == 255) b = 255 - di_INCR; // BUG can't change hue if brightness is 255
      di_Background = color(h, 100, b);
      break;
  
    // Increase/decrease zoom
    case 'Z':
      di_Zoom += 0.1;
      break;
    case 'z':
      di_Zoom -= 0.1;
      break;
    
    default:
      F.doCommand(key);
      break;
  }    

}

private String datename(String prefix, String suffix) {
  String tmp = String.format("%04d%02d%02d%02d%02d%02d", year(), month(), day(), hour(), minute(), second());
  return new String(prefix + tmp + suffix);
}

// save the old family and create a new one
// returns true if new family created
private boolean save_family(diFamily fam) {
  if (!fam.f_Modified) return true;
  fam.f_Modified = false;
  String s = (String)JOptionPane.showInputDialog(null,
     "Save new family:",
     "Save Family",
     JOptionPane.QUESTION_MESSAGE,
     null,
     null,
     fam.f_Name);
  if ((s != null) && (s.length() > 0)) {
    fam.f_Name = s;
    try {
      File path = new File(di_DigiData, fam.f_Name + ".fam");
      OutputStream out = new FileOutputStream(path);
      OutputStreamWriter w = new OutputStreamWriter(out);
      String str = fam.toString();
      w.write(str, 0, str.length());
      w.close();
      out.close();
      return true;
    } catch (IOException i) {
      println("IOException");
      exit();
    }
  }
  return false;
}  

// Reload a family from it's save file, try data dir then user's DigiData dir
private diFamily reload_family(String name) {
  boolean ro = true;
  if (name.equals("Default")) {
    // Special case: default is not saved in a file!
    return new diFamily();
  }
  File fname = new File(dataPath(name + ".fam"));
  if (!fname.exists()) {
    // Try writable, user created family
    ro = false;
    fname = new File(di_DigiData, name + ".fam");
  }
  diFamily f = new diFamily();
  try {
    InputStream in = new FileInputStream(fname);
    InputStreamReader r = new InputStreamReader(in);
    f.loadFamily(r);
    r.close();
    in.close();
  } catch (IOException i) {
    return null;
  }
  f.f_Readonly = ro;
  return (f);
}

// Load families from ".fam" files in dir, set the Readonly flag using ro
private void load_families(File dir, boolean ro) {
  for (File child : dir.listFiles()) {
    if (di_NextFam >= di_Families.length) {
      println("Too many families!");
      return;
    }  
    if (child.getName().endsWith(".fam")) {
      diFamily f = new diFamily();
      try {
        InputStream in = new FileInputStream(child);
        InputStreamReader r = new InputStreamReader(in);
        f.loadFamily(r);
        r.close();
        in.close();
      } catch (IOException i) {
        println("IOException on read");
        exit();
      }
      f.f_Readonly = ro;
      di_Families[di_NextFam++] = f;
    }
  }
}  
      
        

//float random_hue(int low, int high) {
//  float ret;
//  
//  if (low < high) {
//    return (random(low, high));
//  }
//  ret = random(low, low + (256 + low - high)) % 256;
////  println("low=" + low + " high=" + high + " ->" + round(ret));
//  return (ret);
//}  


