/*
The diShape class creates and draws basic shapes
centerx,centery is the center of the drawing area,
wid,hgt are the width and height. Shape should approximately center
in drawing area and reach out to the edges
*/



public class diShape {
  // save initial values to use with niose function base* is the unmodified
  float cx, basex;
  float cy, basey;
  float w, basew;
  float h, baseh;
  float r, baser;
  
  // create a new shape
  diShape(float centerx, float centery, float wid, float hgt) {
    basex = cx = centerx;
    basey = cy = centery;
    basew = w = wid;
    baseh = h = hgt;
    baser = r = random(TWO_PI);
  }

  // display shape on pg
  public void Display(PGraphics pg) {
    return;
  }
  
  // jitter the initial values
  public void AddNoise(float pct) {
    if (pct == 0.0) return;
    cx = addnoise(basex, basew);
    cy = addnoise(basey, baseh);
    w = addnoise(basew, basew/2);
    h = addnoise(baseh, baseh/2);
    r = addnoise(baser, PI);
  }    
}

class diStar extends diShape {
  int points;  // number of point in the star;
  float outer;
  float inner;
  float tightness;
  
  diStar(float cx, float cy, float w, float h) {
    super(cx, cy, w, h);
    points = (int)random(3, 13);
    outer = min(w/2, h/2);
    inner = random(outer);
    tightness = random(-1, 1);
  }

  public void Display(PGraphics pg) { 
    float rot = TWO_PI / points;
    float half_rot = rot / 2.0;

    pg.pushMatrix();
    pg.translate(cx, cy);
    pg.rotate(r);
    pg.curveTightness(tightness);
    pg.beginShape();
    pg.curveVertex(inner * cos(-half_rot), inner * sin(-half_rot));
    for (float cur_rot = 0.0; cur_rot < TWO_PI; cur_rot += rot) {
      pg.curveVertex(outer * cos(cur_rot), outer * sin(cur_rot));
      pg.curveVertex(inner * cos(cur_rot+half_rot), inner * sin(cur_rot+half_rot));
    }
    pg.curveVertex(outer * cos(0), outer * sin(0));
    pg.curveVertex(inner * cos(half_rot), inner * sin(half_rot));

    pg.endShape(CLOSE);
    pg.popMatrix();
  }
}

class diFlower extends diShape {
  int points;
  diShape s;
  int i;
  
  diFlower(float cx, float cy, float w, float h) {
    super(cx, cy, w, h);
    points = round(random(2, 13));
    i = round(random(0, 100));
    // create petal shapes centered on x axis, half way out to the right edge
    if (i < 50) {
      s = new diPetal(w/4, 0, w/2, h/2);
    } else if (i < 75) {
      s = new diEllipse(w/4, 0, w/2, h/2);
    } else {
      s = new diHeart(w/4, 0, w/2, h/2);
    }  
    s.r = 0.0;
  }

  public void Display(PGraphics pg) {  
    float rot = TWO_PI / points;
    int oldfill = pg.fillColor;
    
    pg.pushMatrix();
    pg.translate(cx, cy);
    pg.rotate(r);
    
    // Need to turn down the alpha a bit so flower doesn't overwhelm it
    if (pg.fill) {
      pg.fill(hue(oldfill), saturation(oldfill), brightness(oldfill), alpha(oldfill)/2);
    }  
 
    for (int i = 0; i < points; i++) {
      s.Display(pg);
      pg.rotate(rot);
    }
    
    if (pg.fill) {
      pg.fill(oldfill);
    }
    
    pg.popMatrix();  
  }
}

class diPetal extends diShape {
  
  diPetal(float cx, float cy, float w, float h) {
    super(cx, cy, w, h);
  }

  public void Display(PGraphics pg) {  
    pg.pushMatrix();
    pg.translate(cx, cy);
    pg.rotate(r);
    pg.translate(-w/2, 0);
    pg.bezier(0, 0, w, h/2, w, -(h/2), 0, 0);
    pg.popMatrix();
  }  
}

class diHeart extends diShape {
  diHeart(float cx, float cy, float w, float h) {
    super(cx, cy, w, h);
  }

  // heart is drawn to a 300X300 box so we have to scale it
  public void Display(PGraphics pg) {  
    pg.pushMatrix();
    pg.translate(cx, cy);
    pg.rotate(r);
    pg.translate(-w/2, 0);
    pg.scale(w/300, h/300);
    pg.bezier(0, 0,
           175, 250,
           300, 100,
           200, 0);
    pg.bezier(0, 0,
           175, -250,
           300, -100,
           200, 0);
    pg.popMatrix();
  }   
}
//
//class diQuad extends diShape {
//  diQuad(float cx, float cy, float w, float h) {
//    super(cx, cy, w, h);
//  }
//
//  public void Display(PGraphics pg) {  
//    pg.pushMatrix();
//    pg.translate(cx, cy);
//    pg.rotate(r);
//    pg.quad(0, (h/2), (w/2), 0, 0, -(h/2), -(w/2), 0);
//    pg.popMatrix();
//  }   
//}

class diQuad extends diShape {
  float tightness;
  diQuad(float cx, float cy, float w, float h) {
    super(cx, cy, w, h);
    tightness = random(-1, 1);
  }

  public void Display(PGraphics pg) { 
    float radius = min(w, h); 
    pg.pushMatrix();
    pg.translate(cx, cy);
    pg.rotate(r);
    pg.scale(radius/w, radius/h);
    curveEllipse(pg, 4, radius, tightness);
//    pg.rect(0, 0, w, h);
    pg.popMatrix();
  }   
}


class diTriangle extends diShape {
  float vx, vy;
  diTriangle(float cx, float cy, float w, float h) {
    super(cx, cy, w, h);
    vx = random(-(w/2), 0);
    vy = random(-(h/2), (h/2));
  }

  public void Display(PGraphics pg) { 
    pg.pushMatrix();
    pg.translate(cx, cy);
    pg.rotate(r);
    curveEllipse(pg, 3, min(w, h), 2.0*(vy/h));
//    pg.triangle(w/2, h/2,
//                w/2, -(h/2),
//                vx, vy); 
    pg.popMatrix();            
  }   
}

class diRect extends diShape {
  float tightness;
  diRect(float cx, float cy, float w, float h) {
    super(cx, cy, w, h);
    tightness = random(-1, 1);
  }

  public void Display(PGraphics pg) { 
    float radius = min(w, h); 
    pg.pushMatrix();
    pg.translate(cx, cy);
    pg.scale(radius/w, radius/h);
    pg.rotate(PI/4);
    curveEllipse(pg, 4, radius, tightness);
//    pg.rect(0, 0, w, h);
    pg.popMatrix();
  }   
}

class diEllipse extends diShape {
  diEllipse(float cx, float cy, float w, float h) {
    super(cx, cy, w, h);
  }

  public void Display(PGraphics pg) {  
    pg.pushMatrix();
    pg.translate(cx, cy);
    pg.rotate(r);
    pg.ellipse(0, 0, w, h);
    pg.popMatrix();
  }   
}

public diShape NewShape(float cx, float cy, float w, float h) {
  if (!(F.f_Elipse || F.f_Quad || F.f_Rect || F.f_Star || F.f_Tri || F.f_Petal || F.f_Flower || F.f_Heart) ) {
    // No shapes turned on
    return null;
  }
  
  // loop until we get a shape
  for ( ; ; ) {
    int shape = (int)random(100) % 8;
    switch (shape) {
                
    case 7:
      if (F.f_Heart) return new diHeart(cx, cy, w, h);
      break;
      
    case 6:
      if (F.f_Flower) return new diFlower(cx, cy, w, h);
      break;
        
    case 5:
      if (F.f_Petal) return new diPetal(cx, cy, w, h);
      break;
    
    case 4:
      if (F.f_Elipse) return new diEllipse(cx, cy, w, h);
      break;
      
    case 3:
      if (F.f_Tri) return new diTriangle(cx, cy, w, h);
      break;
    
    case 2:
      if (F.f_Quad) return new diQuad(cx, cy, w, h);
      break;
      
    case 1:
      if (F.f_Rect) return new diRect(cx, cy, w, h);
      break;
    
    case 0:
      if (F.f_Star) return new diStar(cx, cy, w, h);
      break;
    }
  }  
}


void curveEllipse(PGraphics pg, int pts, float radius, float tightness) {
  float theta = 0;
  float cx = 0, cy = 0;
  float ax = 0, ay = 0;
  float rot = TWO_PI/pts;
  
  pg.curveTightness(tightness);
  pg.beginShape();
  for (int i = 0; i < pts; i++) {
    
    // first control point
    if (i == 0) {
      cx = cos(theta - rot) * radius;
      cy = sin(theta - rot) * radius;
      pg.curveVertex(cx, cy);
    } 
    ax = cos(theta) * radius;
    ay = sin(theta) * radius; 
    pg.curveVertex(ax, ay);
    
    // close elipse
    if (i == pts - 1) {
      cx = cos(theta + rot) * radius;
      cy = sin(theta + rot) * radius;
      pg.curveVertex(cx, cy);
      ax = cos(theta + rot * 2) * radius;
      ay = sin(theta + rot * 2) * radius;
      pg.curveVertex(ax, ay);
    }
    theta += rot;
  }
  pg.endShape(CLOSE);
}  

