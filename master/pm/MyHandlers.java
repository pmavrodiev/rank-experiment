package pm;

import java.io.BufferedReader;
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
		public static DateFormat dateFormat = new SimpleDateFormat("HH:mm:ss");

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
					/*Get the POST payload*/
					String payload = getPOSTpayLoad(request);
					String ip = baseRequest.getConnection().getEndPoint().getRemoteAddr();
					Log.print("Client " + ip + " said: " + payload);
					if (payload.equals("announce\n")) {						
						if (GUI.gameRoundsStates[0]) {
							response.getWriter().print("full");
						}
						else {
							/*Has the client already announced himself?
							 *this is possible if a user starts the instruction phase,
							 *then closes the web page and reloads it again. In this way,
							 *no "ready" message will have been received by the server for
							 *this particular user.*/
							ClientLog alreadyAnnounced = GUI.clients.get(ip);						
							if (alreadyAnnounced != null) {
								Log.println("Client already announced. Announcement time updated.\n");
								/*update announcement time*/							
								alreadyAnnounced.reg_begin = dateFormat.format(new Date());
								GUI.updateGUITable(alreadyAnnounced,GUI.RE_ANNOUNCE);
								response.getWriter().print("maxrounds "+GUI.gameRounds);
							}

							else {
								/*add the client to the known clients*/
								Log.println("Client announced from "+ip+"\n");							
								ClientLog newClient = new ClientLog(ip,dateFormat.format(new Date()),null,GUI.clients.size());	
								GUI.clients.put(ip, newClient);
								GUI.updateGUITable(newClient,GUI.ANNOUNCE);  //new client
								response.getWriter().print("maxrounds "+GUI.gameRounds);
							}
						}
					}
					else if (payload.indexOf("rank") != -1) {
						//get the second parameter of the payload which is the round the client wants to start
						//e.g. round 0
						//if the round can be started, update Round_X_BEGIN
						String[] tokenize_payload = payload.split("\\s");
						try {
							Integer requestedRound = new Integer(tokenize_payload[1]);
							if (GUI.gameRoundsStates[requestedRound]) {
								response.getWriter().print("urrank "+requestedRound + " 10(25)");
								String clientTime = dateFormat.format(new Date());
								ClientLog oldClient = GUI.clients.get(ip);
								/*round requestedRound begins*/
								oldClient.initNewRound(clientTime, requestedRound);
								GUI.updateGUITable(oldClient,GUI.ROUND_BEGIN);								
								if (requestedRound == 0) {								
									oldClient.reg_end = clientTime;
									GUI.updateGUITable(oldClient,GUI.REG_END);
								}

							}
							else {
								response.getWriter().print("wait "+requestedRound);
							}
						}
						catch (NumberFormatException e) {
							response.getWriter().print("malformed request " + payload);
						}


					}
					else if (payload.indexOf("estimate") != -1 ) {
						//e.g. estimate 1 12.2348239 
						//estimate of 12.2348239 for round 1
						//the time of receiving this is also the time for Round_X_END
						String[] tokenize_payload = payload.split("\\s");
						try {
							response.getWriter().print("ok");
							Integer estimateForRound = new Integer(tokenize_payload[1]);
							Double clientEstimate = new Double(tokenize_payload[2]);
							String clientTime = dateFormat.format(new Date());
							/* sanity check */
							if (!GUI.gameRoundsStates[estimateForRound]) {
								Log.println("Sanity check failed: Client " + ip +" submitted estimate for finished round.");
							}
							/*update the round info for this client*/
							ClientLog oldClient = GUI.clients.get(ip);
							oldClient.updateRound(clientTime, clientEstimate, estimateForRound);
							GUI.updateGUITable(oldClient,GUI.ROUND_END);

							
						}
						catch (NumberFormatException e) {
							response.getWriter().print("malformed request " + payload);
						}


					}
					else {response.getWriter().print("unknown_request");					}
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
				Log.println("I am boss handler");

				response.setHeader("Access-Control-Allow-Origin", "*");				
				response.setContentType("text/html;charset=utf-8");
				response.setStatus(HttpServletResponse.SC_OK);
				baseRequest.setHandled(true);
				String ip = baseRequest.getConnection().getEndPoint().getRemoteAddr();
				Log.println("Boss connected from "+ip);
				response.getWriter().println("<h1>You are a boss from "+ip+"</h1>");
			}
		}
	}

}
