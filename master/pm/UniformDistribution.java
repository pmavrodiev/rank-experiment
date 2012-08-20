package pm;

import java.util.Random;

/*Sampling from a wrapped normal distribution. 
 *Following Steve Job's moto that "good artists copy great artists steal", this
 *implementation is insolently stolen from the R function rwrappedgaussian in package stats*/

public class UniformDistribution {
	private final static Random r = new Random();	
	
	/*generate a uniform random angle between -pi and pi. returns degrees*/
	public static double pi_uniform() {
		return (r.nextDouble()*2*Math.PI - Math.PI)*180/Math.PI;		
	}

/*
	public static void main(String[] args) {
		int N = 100;
		for (int i=0; i<N; i++)
			System.out.println(pi_uniform());
	}
*/
	
}
