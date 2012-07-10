package pm;

import org.eclipse.jetty.server.nio.SelectChannelConnector;


public class MyConnectors {

	public static SelectChannelConnector client = new SelectChannelConnector();
	public static SelectChannelConnector admin = new SelectChannelConnector();
	public static void initConnectors() {
		//how clients connect
		client.setPort(8080);
		client.setMaxIdleTime(30000);
		client.setRequestHeaderSize(8192);
		//how bosses connect
		admin.setPort(8000);
		admin.setMaxIdleTime(30000);
		admin.setRequestHeaderSize(8192);
	}
}
