package pm;

import java.io.IOException;
import java.io.PipedInputStream;

public class ReaderThread extends Thread {
	PipedInputStream pi;
	ReaderThread(PipedInputStream pi) {
		this.pi = pi;
	}
	public void run() {
		final byte[] buf = new byte[1024];
		try {
			while (true) {
				final int len = pi.read(buf);
				if (len == -1) {
					break;
				}
				GUI.console_output.append(new String(buf, 0, len));

				// Make sure the last line is always visible
				GUI.console_output.setCaretPosition(GUI.console_output.getDocument().getLength());

				// Keep the text area down to a certain character size
				int idealSize = 1000;
				int maxExcess = 500;
				int excess = GUI.console_output.getDocument().getLength() - idealSize;
				if (excess >= maxExcess) {
					GUI.console_output.replaceRange("", 0, excess);
				}
				
			}
		} catch (IOException e) {
		}
	}
}