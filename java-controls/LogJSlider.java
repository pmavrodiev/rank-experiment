/*
 * LogJSlider.java
 *
 * Created on July 14, 2006, 11:10 AM
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package tessonec.controls;

/**
 *
 * @author tessonec
 */
public class LogJSlider extends LinearJSlider {
    
    /** Creates a new instance of LogJSlider */
    public LogJSlider() {
        
       minValue=0.1;
       doubleValue=0.1;
       nf2.applyPattern("#.###E0");
    }

    
    protected int getPosFromValue(){
      
      double b = (double)(getMaximum()) / Math.log(maxValue/minValue);
      int position= (int)( Math.log(doubleValue/minValue) * b );
      
      if(position<0){
        doubleValue=minValue;
        return 0;
      }
      if(position>getMaximum()){
        doubleValue=maxValue;
        return getMaximum();
      }
      
      return position;
    }

    protected void updateValueFromPos(){
        
      double b = 1./(double)(getMaximum()) * Math.log(maxValue/minValue);
      doubleValue = minValue*Math.exp(b*getValue());
    }
    
   


}
