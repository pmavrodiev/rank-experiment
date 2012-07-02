package pm;


 
import org.eclipse.jetty.server.Connector;
import org.eclipse.jetty.server.Handler;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.handler.HandlerList;


import pm.MyConnectors;
import pm.MyHandlers;
 
public class HelloWorld {
    
 
    public static void main(String[] args) throws Exception
    {
        Server server = new Server();
    	MyConnectors.initConnectors();
    	server.setConnectors(new Connector[]{ MyConnectors.client, MyConnectors.admin });        
        
    	HandlerList handlers = new HandlerList();
        handlers.setHandlers(new Handler[] { new MyHandlers.CLIENT(), new MyHandlers.BOSS() });
    	
    	server.setHandler(handlers);
 
        
        
        server.start();
        server.join();
    }
}