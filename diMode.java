public enum diMode {
  ALL, SHAPES, CURVES, SPIRO;
  
  public diMode next()  
    {  
      int index = (this.ordinal() + 1) % this.values().length;  
        return this.values()[index];  
     }
   
   public static diMode parseMode(String str) {
     diMode m;
     if (str.equals(ALL.toString())) m = ALL;
     else if (str.equals(SHAPES.toString())) m = SHAPES;
     else if (str.equals(CURVES.toString())) m = CURVES;
     else if (str.equals(SPIRO.toString())) m = SPIRO;
     else m = ALL;
     return m;
   }  
}

 
