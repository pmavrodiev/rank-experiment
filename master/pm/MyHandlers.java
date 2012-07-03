package pm;

import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.eclipse.jetty.server.Request;
import org.eclipse.jetty.server.handler.AbstractHandler;


public class MyHandlers {

	public static class CLIENT extends AbstractHandler {
		public static int myport = 8080;

		public void handle(String target,Request baseRequest,HttpServletRequest request,
				HttpServletResponse response) throws IOException, ServletException {

			if (baseRequest.getConnection().getConnector().getPort() == myport) {
				response.setHeader("Access-Control-Allow-Origin", "*");
				response.setContentType("text/html;charset=utf-8");			
				response.setStatus(HttpServletResponse.SC_OK);
				baseRequest.setHandled(true);
				String ip = baseRequest.getConnection().getEndPoint().getRemoteAddr();
				System.out.println("Client connected from "+ip);
				response.getWriter().println("OK");
				/*add the client to the known clients*/
				DateFormat dateFormat = new SimpleDateFormat("HH:mm:ss");
				ClientLog newClient = new ClientLog(ip,dateFormat.format(new Date()));				
				GUI.clients.add(newClient);
				GUI.updateGUITable(newClient,GUI.REGISTRATION);  //new client
			}
		}
	}
	
	public static class BOSS extends AbstractHandler {
		public static int myport = 8000;

		public void handle(String target,Request baseRequest,HttpServletRequest request,
				HttpServletResponse response) throws IOException, ServletException {
			
			if (baseRequest.getConnection().getConnector().getPort() == myport) {
				System.out.println("I am boss handler");
				
				response.setHeader("Access-Control-Allow-Origin", "*");				
				response.setContentType("text/html;charset=utf-8");
				response.setStatus(HttpServletResponse.SC_OK);
				baseRequest.setHandled(true);
				String ip = baseRequest.getConnection().getEndPoint().getRemoteAddr();
				System.out.println("Boss connected from "+ip);
				response.getWriter().println("<h1>You are a boss from "+ip+"</h1>");
			}
		}
	}

}
