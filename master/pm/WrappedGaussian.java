package pm;

import java.util.Random;

/*Sampling from a wrapped normal distribution. 
 *Following Steve Job's moto that "good artists copy great artists steal", this
 *implementation is insolently stolen from the R function rwrappedgaussian in package stats*/

public class WrappedGaussian {
	private final static Random r = new Random();	
	
	/*mean angle mu in radians, sigma is the sd of the unwrapped normal distribution. returns degrees*/
	public static double phi_wrapped(double mu, double sigma) {
		if (sigma == 0) return mu;
		return ((mu + sigma*r.nextGaussian()) % (2*Math.PI))*180/Math.PI;
	}

	public static void main(String[] args) {
		int N = 20;
		for (int i=0; i<N; i++)
			System.out.println(phi_wrapped(0,0.05));
	}

	
}
