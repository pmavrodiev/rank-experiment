package pm;

import org.eclipse.jetty.server.nio.SelectChannelConnector;


public class MyConnectors {

	public static SelectChannelConnector client = new SelectChannelConnector();
	public static void initConnectors() {
		//how clients connect
		client.setPort(8070);
		client.setMaxIdleTime(30000);
		client.setRequestHeaderSize(8192);
	}
}
