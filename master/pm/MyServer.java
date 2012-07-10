package pm;

import org.eclipse.jetty.server.Connector;
import org.eclipse.jetty.server.Handler;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.handler.HandlerList;

import pm.MyConnectors;
import pm.MyHandlers;

public class MyServer {

	private Server server;
	public MyServer() throws Exception{
		server = new Server();
		MyConnectors.initConnectors();
		server.setConnectors(new Connector[]{ MyConnectors.client/*, MyConnectors.admin*/ });        

		HandlerList handlers = new HandlerList();

		//WebAppContext webContext = new pm.AppContextBuilder().buildWebAppContext();
		handlers.setHandlers(new Handler[] { new MyHandlers.CLIENT()/*, new MyHandlers.BOSS()*/});

		//webContext.setServer(server);   	
		server.setHandler(handlers);        
	}
	public void start() throws Exception {server.start();}

	public void stop() throws Exception {
		server.stop();
		server.join();
	}

	public boolean isStarted() {return server.isStarted();}

	public boolean isStopped() {return server.isStopped();}
	/*public void setHandler(ContextHandlerCollection contexts) {
		server.setHandler(contexts);
	}*/

}