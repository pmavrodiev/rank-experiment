package pm;

import java.io.PrintStream;

public class Log {
	public static PrintStream ps = System.out;
	public static boolean DEBUG = true;
	public static void println(Object what) {
		if (DEBUG)
			ps.println(what);
	}
	public static void print(Object what) {
		if (DEBUG)
			ps.print(what);
	}
	
}
