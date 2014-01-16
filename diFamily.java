/*
Paramters that define a digitom family. These are the high level "genes"
that control the overall look of randomly generated digitoms that vary
within these parameters.
*/
import java.util.*;
import java.io.*;
import java.lang.reflect.Field;
import java.util.Properties;


public class diFamily implements Serializable {
    
  // General constants
  static final int WHEELINCR = 5;  // amount to grow or shrink wheel
  static final float ERRORINCR = 0.1f;    // amount to grow or shrink error
  static final int COLORINCR = 5;  // amount to change color values
  static final float LINEINCR = 0.5f;

  static transient Random R = new Random();
  transient boolean f_Modified = false;    // true if family has been modified since save
  transient boolean f_Readonly = true;     // true if family cannot be modified
  
  // Name of the family
  String f_Name = "Default";
  
  // Current drawing mode
  diMode f_Mode = diMode.ALL;
  
  // Line weight
  float f_LineWeight = 1;
  
  // Number of rotations
  int f_Nrot = 13;
  
  // Percent error to introduce into drawing
  float f_Error = 0.0f;    // percent error
  
  // shapes mode: number of rect, quad, elipse and stars
  boolean f_Elipse = true;
  boolean f_Quad = true;
  boolean f_Rect = true;
  boolean f_Star = true;
  boolean f_Tri = true;
  boolean f_Petal = true;
  boolean f_Flower = true;
  boolean f_Heart = true;
  int f_Nshapes = 13;  // # shapes, set by +/-
  boolean f_Fill = true;
      
  // spiro mode: wheel radius r1 and r2 and pen pos on r2 all %
  int f_R1 = 66;  // percent of screen
  int f_R2 = 50;  // percent of R1
  int f_Rpen = 100;  //percent of R2
  int f_Step = 40;  // angle per step, set by +/-
  int f_SpiroDensity = 13; // multiplier for Nrot to increase/decrease density
 
  // Curves mode: number of lines
  int f_Nlines = 27;  // number of lines, set by +/-
      
  // color control: hue, sat, value, opacity ranges, line weight, fill
  int f_Hue = 130;
  int f_HueRange = 256;
  int f_HueLow = 2;  // Hue wraps around at 255. HueLow == HueHigh -> whole range
  int f_HueHigh = 2;
  int f_Sat = 200;
  int f_SatRange = 100;
  int f_SatLow = f_Sat - (f_SatRange/2);
  int f_SatHigh = f_Sat + (f_SatRange/2);
  int f_Val = 200; // Value == brightness
  int f_ValRange = 100;
  int f_ValLow = f_Val - (f_ValRange/2);
  int f_ValHigh = f_Val + (f_ValRange/2);
  int f_Alpha = 100;
  int f_AlphaRange = 60;
  int f_AlphaLow = f_Alpha - (f_AlphaRange/2);
  int f_AlphaHigh = f_Alpha + (f_AlphaRange/2);

  /**
   * toString returns a string with field=value\n
   * New fields should be added at the end of the list for backward compatability
   */
  @Override public String toString() {
    StringBuilder result = new StringBuilder();
    String newLine = System.getProperty("line.separator");

    result.append("Name" + "=" + f_Name + newLine);
    result.append("Mode" + "=" + f_Mode + newLine);
    result.append("LineWeight" + "=" + f_LineWeight + newLine);
    result.append("Nrot" + "=" + f_Nrot + newLine);
    result.append("Error" + "=" + f_Error + newLine);
    result.append("Elipse" + "=" + f_Elipse + newLine);
    result.append("Quad" + "=" + f_Quad + newLine);
    result.append("Rect" + "=" + f_Rect + newLine);
    result.append("Star" + "=" + f_Star + newLine);
    result.append("Tri" + "=" + f_Tri + newLine);
    result.append("Petal" + "=" + f_Petal + newLine);
    result.append("Flower" + "=" + f_Flower + newLine);
    result.append("Heart" + "=" + f_Heart + newLine);
    result.append("Nshapes" + "=" + f_Nshapes + newLine);
    result.append("Fill" + "=" + f_Fill + newLine);
    result.append("R1" + "=" + f_R1 + newLine);
    result.append("R2" + "=" + f_R2 + newLine);
    result.append("Rpen" + "=" + f_Rpen + newLine);
    result.append("Step" + "=" + f_Step + newLine);
    result.append("SpiroDensity" + "=" + f_SpiroDensity + newLine);
    result.append("Nlines" + "=" + f_Nlines + newLine);
    result.append("Hue" + "=" + f_Hue + newLine);
    result.append("HueRange" + "=" + f_HueRange + newLine);
    result.append("Sat" + "=" + f_Sat + newLine);
    result.append("SatRange" + "=" + f_SatRange + newLine);
    result.append("Val" + "=" + f_Val + newLine);
    result.append("ValRange" + "=" + f_ValRange + newLine);
    result.append("Alpha" + "=" + f_Alpha + newLine);
    result.append("AlphaRange" + "=" + f_AlphaRange + newLine);
    return result.toString();
  }

  public void loadFamily(Reader in) {
    Properties prop = new Properties();
    
    try {
      prop.load(in);
    } catch (IOException e) {
      e.printStackTrace();
      return;
    }
    String val;
    if ((val = prop.getProperty("Name")) != null) f_Name = val;
    if ((val = prop.getProperty("Mode")) != null)  f_Mode = diMode.parseMode(val);
    if ((val = prop.getProperty("LineWeight")) != null)  f_LineWeight = Float.parseFloat(val);
    if ((val = prop.getProperty("Nrot")) != null)  f_Nrot = Integer.parseInt(val);
    if ((val = prop.getProperty("Error")) != null)  f_Error = Float.parseFloat(val);
    if ((val = prop.getProperty("Elipse")) != null)  f_Elipse = Boolean.parseBoolean(val);
    if ((val = prop.getProperty("Quad")) != null)  f_Quad = Boolean.parseBoolean(val);
    if ((val = prop.getProperty("Rect")) != null)  f_Rect = Boolean.parseBoolean(val);
    if ((val = prop.getProperty("Star")) != null)  f_Star = Boolean.parseBoolean(val);
    if ((val = prop.getProperty("Tri")) != null)  f_Tri = Boolean.parseBoolean(val);
    if ((val = prop.getProperty("Petal")) != null)  f_Petal = Boolean.parseBoolean(val);
    if ((val = prop.getProperty("Flower")) != null)  f_Flower = Boolean.parseBoolean(val);
    if ((val = prop.getProperty("Heart")) != null)  f_Heart = Boolean.parseBoolean(val);
    if ((val = prop.getProperty("Nshapes")) != null)  f_Nshapes = Integer.parseInt(val);
    if ((val = prop.getProperty("Fill")) != null)  f_Fill = Boolean.parseBoolean(val);
    if ((val = prop.getProperty("R1")) != null)  f_R1 = Integer.parseInt(val);
    if ((val = prop.getProperty("R2")) != null)  f_R2 = Integer.parseInt(val);
    if ((val = prop.getProperty("Rpen")) != null)  f_Rpen = Integer.parseInt(val);
    if ((val = prop.getProperty("Step")) != null)  f_Step = Integer.parseInt(val);
    if ((val = prop.getProperty("SpiroDensity")) != null)  f_SpiroDensity = Integer.parseInt(val);
    if ((val = prop.getProperty("Nlines")) != null)  f_Nlines = Integer.parseInt(val);
    if ((val = prop.getProperty("Hue")) != null)  f_Hue = Integer.parseInt(val);
    if ((val = prop.getProperty("HueRange")) != null)  f_HueRange = Integer.parseInt(val);
    if ((val = prop.getProperty("Sat")) != null)  f_Sat = Integer.parseInt(val);
    if ((val = prop.getProperty("SatRange")) != null)  f_SatRange = Integer.parseInt(val);
    if ((val = prop.getProperty("Val")) != null)  f_Val = Integer.parseInt(val);
    if ((val = prop.getProperty("ValRange")) != null)  f_ValRange = Integer.parseInt(val);
    if ((val = prop.getProperty("Alpha")) != null)  f_Alpha = Integer.parseInt(val);
    if ((val = prop.getProperty("AlphaRange")) != null)  f_AlphaRange = Integer.parseInt(val);
    fix_hue();
    fix_sat();
    fix_val();
    fix_opacity();
    f_Readonly = true;
    f_Modified = false;
  }

  // default family, just use initial values
  diFamily() { 
    return;
  }
  
  // Create a new family that is a dup of an existing one but with a new name and modifiable
  diFamily(diFamily old, String newname) { 
    f_Name = newname;
    f_Readonly = false;
    f_Modified = true;
    f_Mode = old.f_Mode;
    f_LineWeight = old.f_LineWeight;
    f_Nrot = old.f_Nrot;
    f_Error = old.f_Error;
    f_Elipse = old.f_Elipse;
    f_Quad = old.f_Quad;
    f_Rect = old.f_Rect;
    f_Star = old.f_Star;
    f_Tri = old.f_Tri;
    f_Petal = old.f_Petal;
    f_Flower = old.f_Flower;
    f_Heart = old.f_Heart;
    f_Nshapes = old.f_Nshapes;
    f_Fill = old.f_Fill;
    f_R1 = old.f_R1;
    f_R2 = old.f_R2;
    f_Rpen = old.f_Rpen;
    f_Step = old.f_Step;
    f_SpiroDensity = old.f_SpiroDensity;
    f_Nlines = old.f_Nlines;
    f_Hue = old.f_Hue;
    f_HueRange = old.f_HueRange;
    f_HueLow = old.f_HueLow;
    f_HueHigh = old.f_HueHigh;
    f_Sat = old.f_Sat;
    f_SatRange = old.f_SatRange;
    f_SatLow = old.f_SatLow;
    f_SatHigh = old.f_SatHigh;
    f_Val = old.f_Val;
    f_ValRange = old.f_ValRange;
    f_ValLow = old.f_ValLow;
    f_ValHigh = old.f_ValHigh;
    f_Alpha = old.f_Alpha;
    f_AlphaRange = old.f_AlphaRange;
    f_AlphaLow = old.f_AlphaLow;
    f_AlphaHigh = old.f_AlphaHigh;
    return;
  }  

  // New random family, modifiable
  diFamily(String name) { 
    int m = R.nextInt(100);
    
    f_Name = name;
    f_Modified = true;
    f_Readonly = false;
    
    if (m < 60) {
      f_Mode = diMode.ALL;
    } else if (m < 80) {
      f_Mode = diMode.SHAPES;
    } else if (m < 90) {
      f_Mode = diMode.CURVES;
    } else {
      f_Mode = diMode.SPIRO;
    }
    
    // shapes on/off coin flip
    f_Elipse = R.nextBoolean();
    f_Quad = R.nextBoolean();
    f_Rect = R.nextBoolean();
    f_Star = R.nextBoolean();
    f_Tri = R.nextBoolean();
    f_Petal = R.nextBoolean();
    f_Flower = R.nextBoolean();
    f_Heart = R.nextBoolean();
    
    // fill on 75% of the time
    f_Fill = (R.nextInt(100) <= 75);
    
    // # shapes avg 13, sigma 2
    f_Nshapes = Math.round(gaussian(13.0f, 5.0f, 1.0f, 25.0f));
    
    // spiro wheel sizes, pen offset and step size, pump it up in SPIRO only
    if (f_Mode == diMode.SPIRO) {
      f_SpiroDensity = Math.round(gaussian(27, 10, 13, 50));
    } else {
      f_SpiroDensity = Math.round(gaussian(13, 5, 1, 25));
    }  
    f_Step = Math.round(gaussian(25, 10, 1, 50));
    f_R1 = 50 + R.nextInt(50);
    f_R2 = 50 + R.nextInt(50);
    f_Rpen = 50 + R.nextInt(50);
    
    // # lines in curves mode, pump it up if only curves
    if (f_Mode == diMode.CURVES) {
      f_Nlines = Math.round(gaussian(100, 25, 1, 150));
    } else {
      f_Nlines = Math.round(gaussian(27, 7, 1, 35)); 
    }  
    
    // Start and range for hue, sat, val and alpha
    f_Hue = R.nextInt(256);
    f_HueRange = R.nextInt(206) + 50;  // Math.round(random(50, 255));
    f_HueLow = f_Hue - (f_HueRange/2);
    if (f_HueLow < 0)
      f_HueLow += 256;
    f_HueHigh = (f_Hue + f_HueRange/2) % 256;
    
    // Saturation in the 
    f_SatHigh = Math.round(gaussian(175, 50, 5, 255));
    f_SatLow = Math.round(gaussian((float)f_SatHigh/2, 25, 25, (float)f_SatHigh));
    f_SatRange = (f_SatHigh - f_SatLow) / 2;
    f_Sat = f_SatLow + f_SatRange / 2;
    
    // Lean toward a narrow value range for more pleasing mix of colors
    f_Val = Math.round(gaussian(150, 50, 25, 255));
    f_ValRange = Math.round(gaussian(50, 25, 10, 250));
    f_ValHigh = Math.min((f_Val + f_ValRange/2), 255);
    f_ValLow = Math.max((f_Val - f_ValRange/2), 50);
    f_Val = Math.round((float)(f_ValHigh + f_ValRange) / 2);
    
    // allow lots of alpha range
    f_AlphaHigh = Math.round(gaussian(150, 50, 100, 255));
    f_AlphaLow = Math.round(gaussian((float)f_AlphaHigh/7, 25, 25, f_AlphaHigh));
    f_AlphaRange = (f_AlphaHigh - f_AlphaLow) / 2;
    f_Alpha = f_AlphaLow + f_AlphaRange / 2;
    
    // attempt at a bimodal centered at 1.5 and 45
    f_LineWeight = (R.nextInt(100) < 95)
                    ? gaussian(10, 7, 1, 25)/10 
                    : Math.round(gaussian(45, 10, 3, 55));
                    
    // another bimodal on error centered on 0.5 and 5  
    f_Error = (R.nextInt(100) < 90)
                    ? gaussian(0.5f, 0.5f, 0, 5)
                    : gaussian(5, 1, 0, 10); 
    
    // # rotations                
    f_Nrot = 1 + R.nextInt(36);
    return;
  }
  
  /**
   * Interpret the key pressed as a command to change the family
   */
  public void doCommand(char key) {
        
    // Cycle modes
    if (key == 'm') {
      f_Mode = f_Mode.next();
      f_Modified = true;
      return;
    }
    
    // +/- incr/decr density of objects, depends on mode
    if (key == '+') {
      if (f_Mode == diMode.CURVES) {
          f_Nlines++;
      } else if (f_Mode == diMode.SHAPES) {
          f_Nshapes++;
      } else if (f_Mode == diMode.SPIRO) {
          f_SpiroDensity++;
      } else if (f_Mode == diMode.ALL) {
          f_Nlines++;
          f_Nshapes++;
          f_SpiroDensity++;
      }  
      f_Modified = true;
      return;
    }
  
    // change density, depends on mode
    if (key == '-') {
      if (f_Mode ==  diMode.CURVES) {
          if (f_Nlines > 1) f_Nlines--;
      } else if (f_Mode ==  diMode.SHAPES) {
          if (f_Nshapes > 1) f_Nshapes--;
      } else if (f_Mode ==  diMode.SPIRO) {
          if (f_SpiroDensity > 1) f_SpiroDensity--;
      } else if (f_Mode ==  diMode.ALL) {
          if (f_Nlines > 1) f_Nlines--;
          if (f_Nshapes > 1) f_Nshapes--;
          if (f_SpiroDensity > 1) f_SpiroDensity--;
      }  
      f_Modified = true;
      return;
    }
    
    // set number of rotations (angle)
    if (key == 'a') {
      if (f_Nrot == 1) return;
      f_Nrot--;
      f_Modified = true;
      return;
    }
    if (key == 'A') {
      f_Nrot++;
      f_Modified = true;
      return;
    }
    
    // Set error %
    if (key == 'e') {
      if (f_Error <= ERRORINCR) return;
      f_Error -= ERRORINCR;
      f_Modified = true;
      return;
    }
    if (key == 'E') {
      if (f_Error == 100.0) return;
      f_Error += ERRORINCR;
      if (f_Error > 100.0) f_Error = 100.0f;
      f_Modified = true;
      return;
    }  
  
    // color and color range
    if (key == 'h') {
      f_Hue -= COLORINCR;
      if (f_Hue < 0) f_Hue = 255;
      fix_hue();
      f_Modified = true;
      return;
    }
    if (key == 'H') {
      f_Hue = (f_Hue + COLORINCR) % 256;
      fix_hue();
      f_Modified = true;
      return;
    }
    if (key == '(') {
      f_HueRange -= COLORINCR;
      if (f_HueRange < 3) f_HueRange = 3;
      fix_hue();
      f_Modified = true;
      return;
    }
    if (key == ')') {
      f_HueRange += COLORINCR;
      if (f_HueRange > 256) f_HueRange = 256;
      fix_hue();
      f_Modified = true;
      return;
    }
    if (key == 's') {
      f_Sat -= COLORINCR;
      if (f_Sat < 0) f_Sat = 0;
      fix_sat();
      f_Modified = true;
      return;
    }
    if (key == 'S') {
      f_Sat += COLORINCR;
      if (f_Sat > 255) f_Sat = 255;
      fix_sat();
      f_Modified = true;
      return;
    }
    if (key == '{') {
      f_SatRange -= COLORINCR;
      if (f_SatRange < 1) f_SatRange = 1;
      fix_sat();
      f_Modified = true;
      return;
    }
    if (key == '}') {
      f_SatRange += COLORINCR;
      if (f_SatRange > 255) f_SatRange = 255;
      fix_sat();
      f_Modified = true;
      return;
    }
    if (key == 'v') {
      f_Val -= COLORINCR;
      if (f_Val < 0) f_Val = 0;
      fix_val();
      f_Modified = true;
      return;
    }
    if (key == 'V') {
      f_Val += COLORINCR;
      if (++f_Val > 255) f_Val = 255;
      fix_val();
      f_Modified = true;
      return;
    }
    if (key == '[') {
      f_ValRange -= COLORINCR;
      if (f_ValRange < 0) f_ValRange = 0;
      fix_val();
      f_Modified = true;
      return;
    }
    if (key == ']') {
      f_ValRange += COLORINCR;
      if (f_ValRange > 255) f_ValRange = 255;
      fix_val();
      f_Modified = true;
      return;
    }
    // Opacity (alpha)
    if (key == 'o') {
      f_Alpha -= COLORINCR;
      if (f_Alpha < 0) f_Alpha = 0;
      fix_opacity();
      f_Modified = true;
      return;
    }
    if (key == 'O') {
      f_Alpha += COLORINCR;
      if (f_Alpha > 255) f_Alpha = 255;
      fix_opacity();
      f_Modified = true;
      return;
    }
    if (key == '<') {
      f_AlphaRange -= COLORINCR;
      if (f_AlphaRange < 1) f_AlphaRange = 1;
      fix_opacity();
      return;
    }
    if (key == '>') {
      f_AlphaRange += COLORINCR;
      if (f_AlphaRange > 255) f_AlphaRange = 255;
      fix_opacity();
      f_Modified = true;
      return;
    }
  
    // Line params
    if (key == 'l') {
      if (f_LineWeight <= LINEINCR) {
        f_LineWeight /= 2.0;
      } else { 
        f_LineWeight -= LINEINCR;
      }  
      f_Modified = true;
      return;
    }
    if (key == 'L') {
      f_LineWeight += 0.5;
      f_Modified = true;
      return;
    }
  
    // Fill on/off
    if (key == 'f') {
      f_Fill = !f_Fill;
      f_Modified = true;
    }
  
    if (f_Mode == diMode.ALL || f_Mode == diMode.SHAPES) {
      if (key == '1') {
        f_Elipse = !f_Elipse;
        f_Modified = true;
        return;
      }
      if (key == '2') {
        f_Tri = !f_Tri;
        f_Modified = true;
        return;
      }
      if (key == '3') {
        f_Quad = !f_Quad;
        f_Modified = true;
        return;
      }
      if (key == '4') {
        f_Rect = !f_Rect;
        f_Modified = true;
        return;
      }
      if (key == '5') {
        f_Star = !f_Star;
        f_Modified = true;
        return;
      }
      if (key == '6') {
        f_Petal = !f_Petal;
        f_Modified = true;
        return;
      }
      if (key == '7') {
        f_Flower = !f_Flower;
        f_Modified = true;
        return;
      }
      if (key == '8') {
        f_Heart = !f_Heart;
        f_Modified = true;
        return;
      }
    }
    if (f_Mode == diMode.ALL || f_Mode == diMode.SPIRO) {
      if (key == 'w') {
        f_R1 -= WHEELINCR;
        if (f_R1 < 1) f_R1 = 1;
        f_Modified = true;
        return;
      }
      if (key == 'W') {
        f_R1 += WHEELINCR;
        if (f_R1 > 100) f_R1 = 100;
        f_Modified = true;
        return;
      }
      if (key == 'd') {
        f_R2 -= WHEELINCR;
        if (f_R2 < 1) f_R2 = 1;
        f_Modified = true;
        return;
      }
      if (key == 'D') {
        f_R2 += WHEELINCR;
        if (f_R2 > 100) f_R2 = 100;
        f_Modified = true;
        return;
      }
      if (key == 'p') {
        if (--f_Rpen < 1) f_Rpen = 1;
        f_Modified = true;
        return;
      }
      if (key == 'P') {
        if (++f_Rpen > 100) f_Rpen = 100;
        f_Modified = true;
        return;
      }
      if (key == 'j') {
        if (--f_Step < 1) f_Step = 1;
        f_Modified = true;
        return;
      }
      if (key == 'J') {
        f_Step++;
        f_Modified = true;
        return;
      }  
    }
    if (f_Mode == diMode.ALL || f_Mode == diMode.CURVES) {
      // Don't need to do anything because the only param is f_Nlines
      return;
    }
  }
    
  // Hue wraps around at 255
  private void fix_hue() {
    int new_low = f_Hue - (f_HueRange/2);
    
    if (new_low < 0)
      f_HueLow = 256 + new_low;
    else
      f_HueLow = new_low;
    f_HueHigh = (f_Hue + f_HueRange/2) % 256;
  
  }
  
  // Saturation goes between 0-255
  private void fix_sat() {
    f_SatLow = Math.max(f_Sat - (f_SatRange/2), 0);
    f_SatHigh = Math.min(f_Sat + (f_SatRange/2), 255);
  }
  
  private void fix_val() {
    f_ValLow = Math.max(f_Val - (f_ValRange/2), 0);
    f_ValHigh = Math.min(f_Val + (f_ValRange/2), 255);
  }
  
  private void fix_opacity() {
    f_AlphaLow = Math.max(f_Alpha - (f_AlphaRange/2), 0);
    f_AlphaHigh = Math.min(f_Alpha + (f_AlphaRange/2), 255);
  }

  
  // return a psudo gaussian instance between minval and maxval with
  // given average and std deviation
  float gaussian(float avg, float sigma, float minval, float maxval) {
    float p = 0.0f;
    
    do {
      p = ((float)R.nextGaussian() * sigma + avg);
    } while (p < minval || p > maxval);  
    return (p);
  }
}  
