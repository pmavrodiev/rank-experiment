package pm;

import java.io.IOException;
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
				System.out.println("Client connected");
				//response.setContentType("text/html;charset=utf-8");
			
				response.setStatus(HttpServletResponse.SC_OK);
				baseRequest.setHandled(true);
				String ip = baseRequest.getConnection().getEndPoint().getRemoteAddr();
				response.getWriter().println("<h1>You are a simple client from "+ip+"</h1>");
				
			}
		}
	}
	
	public static class BOSS extends AbstractHandler {
		public static int myport = 8000;

		public void handle(String target,Request baseRequest,HttpServletRequest request,
				HttpServletResponse response) throws IOException, ServletException {

			if (baseRequest.getConnection().getConnector().getPort() == myport) {
				response.setContentType("text/html;charset=utf-8");
				response.setStatus(HttpServletResponse.SC_OK);
				baseRequest.setHandled(true);
				String ip = baseRequest.getConnection().getEndPoint().getRemoteAddr();
				response.getWriter().println("<h1>You are a boss from "+ip+"</h1>");
			}
		}
	}


}
