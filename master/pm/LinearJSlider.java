/*
 * LinearJSlider.java
 *
 * Created on April 22, 2004, 2:08 PM
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package pm;

/**
 *
 * @author tessonec. modified by pmavrodiev
 */
public class LinearJSlider extends javax.swing.JSlider {

	private String label = "";
	protected double doubleValue = 0.;
	protected double minValue;
	protected double maxValue;

	protected java.text.DecimalFormat nf2 = new java.text.DecimalFormat("###.####");

	private void updateBorder(){
		this.setBorder(   new javax.swing.border.TitledBorder(label+"="+nf2.format(doubleValue)) );
		//this.repaint();


	}

	/** Creates a new instance of TitledJSlider */
	public LinearJSlider(double min, double max,final String label) {
		super(  javax.swing.JSlider.HORIZONTAL);//, 0, 1000, 500  );
		this.minValue = min;
		this.maxValue = max;
		this.label = label;
		updateBorder();
		this.addChangeListener(new javax.swing.event.ChangeListener() {
			public void stateChanged(javax.swing.event.ChangeEvent evt) {
				updateValueFromPos(); 
				updateBorder();
			}
		});


	}

	/** Setter for property label.
	 * @param label New value of property label.
	 *
	 */
	public void setLabel(java.lang.String label) {
		this.label = label;
		updateBorder();
	}



	/** Setter for property minValue.
	 * @param minValue New value of property minValue.
	 *
	 */
	public void setMinValue(double minValue) {
		this.minValue = minValue;
		setValue(getPosFromValue());
	}

	/** Setter for property maxValue.
	 * @param maxValue New value of property maxValue.
	 *
	 */
	public void setMaxValue(double maxValue) {
		this.maxValue = maxValue;
		setValue(getPosFromValue());
	}


	public void setFormat(String fmt){
		nf2 = new java.text.DecimalFormat(fmt);
	}

	/** Getter for property value.
	 * @return Value of property value.
	 *
	 */
	public double getDoubleValue() {
		return doubleValue;
	}

	/** Setter for property doubleValue.
	 * @param doubleValue New value of property doubleValue.
	 *
	 */
	public void setDoubleValue(double doubleValue) {
		this.doubleValue = doubleValue;
		setValue(getPosFromValue());
	}    

	protected int getPosFromValue(){

		int position= (int)( (doubleValue-minValue)*(getMaximum()-getMinimum())/(maxValue-minValue));

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
		doubleValue = (double)getValue()*(maxValue-minValue)/(getMaximum()-getMinimum())+minValue ;
	}


}
