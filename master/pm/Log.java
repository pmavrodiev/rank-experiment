package pm;

import java.io.PrintStream;

public class Log {
	//public PrintStream ps;
	public boolean DEBUG;

	public Log(boolean shouldwelog) {
		//ps = System.out;
		DEBUG = shouldwelog;
	}

	public void println(Object what) {
		if (DEBUG)
			//ps.println(what);
			System.out.println(what);
	}
	public void print(Object what) {
		if (DEBUG)
			//ps.print(what);
			System.out.print(what);
	}

}
