package pm;


import java.security.PermissionCollection;

import org.eclipse.jetty.server.handler.ContextHandler;
import org.eclipse.jetty.webapp.WebAppContext;

public class AppContextBuilder {
	private WebAppContext webAppContext;

	
	public WebAppContext buildWebAppContext(){
		webAppContext = new WebAppContext();
		webAppContext.setDescriptor("pm/WEB-INF/web2.xml");
		webAppContext.setResourceBase(".");
		webAppContext.setContextPath("/");
		
		
		return webAppContext;
	}
}
