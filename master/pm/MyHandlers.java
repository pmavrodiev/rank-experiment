package pm;

import java.io.BufferedReader;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.eclipse.jetty.server.Request;
import org.eclipse.jetty.server.handler.AbstractHandler;


public class MyHandlers {

	public static class CLIENT extends AbstractHandler {
		public static int myport = 8080;
		private String getPOSTpayLoad(HttpServletRequest request) throws IOException {
			BufferedReader reader = request.getReader();
			StringBuilder sb = new StringBuilder();
			String line;// = reader.readLine();
			while ((line=reader.readLine()) != null) 
				sb.append(line + "\n");

			reader.close();
			return sb.toString();
		}

		public void handle(String target,Request baseRequest,HttpServletRequest request,
				HttpServletResponse response) throws IOException, ServletException {

			if (baseRequest.getConnection().getConnector().getPort() == myport) {
				response.setHeader("Access-Control-Allow-Origin", "*");
				response.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
				response.setHeader("Access-Control-Allow-Headers", "Content-Type");
				response.setContentType("text/html;charset=utf-8");			
				response.setStatus(HttpServletResponse.SC_OK);
				if (baseRequest.getMethod().equals("POST")) {
					/*get the POST payload*/
					String payload = getPOSTpayLoad(request);
					if (payload.equals("announce\n")) {
						String ip = baseRequest.getConnection().getEndPoint().getRemoteAddr();					
						response.getWriter().println("OK");
						System.out.println("Client announced from "+ip);
						/*add the client to the known clients*/
						DateFormat dateFormat = new SimpleDateFormat("HH:mm:ss");
						ClientLog newClient = new ClientLog(ip,dateFormat.format(new Date()));				
						GUI.clients.add(newClient);
						GUI.updateGUITable(newClient,GUI.REGISTRATION);  //new client
					}
					else if (payload.equals("ready\n")) { //update RegEnd
						//check gameRoundsStates
					}
					else if (payload.indexOf("round") != -1) {
						//get the second parameter of the payload which is the round the client wants to start
						//e.g. round 0
						//if the round can be started, update Round_X_BEGIN
					}
					else if (payload.indexOf("estimate") != -1 ) {
						//e.g. estimate 12.2348239 1
						//estimate of 12.2348239 for round 1
						//the time of receiving this is also the time for Round_X_END
					}
				}
				baseRequest.setHandled(true);			
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
