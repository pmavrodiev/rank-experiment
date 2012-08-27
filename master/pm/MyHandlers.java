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
		public static int myport = 8070;
		public static DateFormat dateFormat = new SimpleDateFormat("HH:mm:ss");
		public static Log log = new Log(false);

		private String getUserName(HttpServletRequest request) throws IOException {
			Enumeration<String> headerNames = request.getHeaderNames();
			String customIdentity="";
			while (headerNames.hasMoreElements()) {
				String headerName = headerNames.nextElement();
				if (headerName.equals("Username")) {
					customIdentity = request.getHeader(headerName);
					break;
				}									
			}
			return customIdentity;			
		}


		private String getHex(HttpServletRequest request) throws IOException {
			Enumeration<String> headerNames = request.getHeaderNames();
			String customIdentity="";
			while (headerNames.hasMoreElements()) {
				String headerName = headerNames.nextElement();
				if (headerName.equals("Hex")) {
					customIdentity = request.getHeader(headerName);
					break;
				}									
			}
			return customIdentity;			
		}

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
				response.setHeader("Access-Control-Allow-Headers", "Content-Type,Hex,Username");
				response.setContentType("text/html;charset=utf-8");			
				response.setStatus(HttpServletResponse.SC_OK);
				if (baseRequest.getMethod().equals("POST")) {
					/*Get the POST payload*/					
					String payload = getPOSTpayLoad(request);
					String hex = getHex(request);					
					String ip = baseRequest.getConnection().getEndPoint().getRemoteAddr();
					log.print("Client " + hex + " said: " + payload);
					if (payload.equals("announce\n")) {						
						if (GUI.finished) {
							response.getWriter().print("finished");
						}
						else if (GUI.inprogress) {
							response.getWriter().print("inprogress");
						}
						else {
							/*Has the client already announced himself?
							 *this is possible if a user starts the instruction phase,
							 *then closes the web page and reloads it again. In this way,
							 *no "ready" message will have been received by the server for
							 *this client.*/
							ClientLog alreadyAnnounced = GUI.clients.get(hex);						
							if (alreadyAnnounced != null) {
								log.println("Client already announced. Announcement time updated.\n");
								/*update announcement time*/							
								alreadyAnnounced.reg_begin = dateFormat.format(new Date());
								GUI.updateGUITable(alreadyAnnounced,GUI.RE_ANNOUNCE);
								response.getWriter().print("maxroundsstages "+GUI.gameRounds+ " "+GUI.gameStages);
							}

							else {
								/*add the client to the known clients*/
								log.println("Client announced from "+ip+":"+hex+"\n");							
								ClientLog newClient = new ClientLog(ip,hex,dateFormat.format(new Date()),null,GUI.clients.size(),UniformDistribution.pi_uniform());
								synchronized (this) {									
									GUI.clients.put(hex, newClient);
									GUI.updateGUITable(newClient,GUI.ANNOUNCE);  //new client									
								}
								response.getWriter().print("maxroundsstages "+GUI.gameRounds+ " "+GUI.gameStages);
							}
						}
					}
					else if (payload.indexOf("rank") != -1) {
						/*check if the client is legit, i.e. has already announced himself*/
						ClientLog alreadyAnnounced = GUI.clients.get(hex);						
						if (alreadyAnnounced != null) {
							/*get the second parameter of the payload which is the round 
							 * the client wants to start, e.g. round 0	
							 * if the round can be started, update Round_X_BEGIN*/
							String[] tokenize_payload = payload.split("\\s");
							ClientLog oldClient = GUI.clients.get(hex);

							try {
								Integer requestedRound = new Integer(tokenize_payload[1]);
								Integer requestedStage = new Integer(tokenize_payload[2]);
								if (requestedRound < GUI.next_round-1) {
									response.getWriter().print("roundfinished");
									baseRequest.setHandled(true);
									return;
								}
								if (requestedStage < GUI.next_stage - 1) {
									response.getWriter().print("stagefinished");
									baseRequest.setHandled(true);
									return;
								}
								if (GUI.gameStagesStates[requestedStage] && GUI.gameRoundsStates[requestedRound]) {
									/*update the username info*/
									if (requestedRound == 0 && requestedStage == 0) {
										String username = getUserName(request);
										oldClient.username = username;
										GUI.updateGUITable(oldClient, GUI.USERNAME);
									}
									int myRank = GUI.currentRanks.get(oldClient.id);
									double initialOffsetEstimate = (GUI.currentEstimates.get(oldClient.id)+oldClient.personalOffset)*Math.PI/180; //in radians									
									oldClient.getRound(requestedRound).setRank(myRank);
									if (requestedRound == 0)
										response.getWriter().print("urrank "+requestedRound + " " + myRank +"("+GUI.activeClients+")" + " " + initialOffsetEstimate);
									else
										response.getWriter().print("urrank "+requestedRound + " " + myRank +"("+GUI.activeClients+")");
									if (requestedRound < GUI.gameRounds) {
										String clientTime = dateFormat.format(new Date());								
										/*round requestedRound begins*/
										oldClient.initNewRound(clientTime, requestedRound);
										GUI.updateGUITable(oldClient,GUI.ROUND_BEGIN);								
									}
								} //end if GUI.gameStagesStates[requestedStage]
								else
									response.getWriter().print("wait "+requestedRound);
							}
							catch (NumberFormatException e) {
								response.getWriter().print("malformed request " + payload);
							}
						} //if (alreadyAnnounced != null) 

					}
					else if (payload.indexOf("estimate") != -1 ) {
						//e.g. estimate 1 12.2348239 
						//estimate of 12.2348239 for round 1
						//the time of receiving this is also the time for Round_X_END
						String[] tokenize_payload = payload.split("\\s");
						try {							
							Integer estimateForRound = new Integer(tokenize_payload[1]);
							Integer estimateForStage = new Integer(tokenize_payload[2]);
							Double clientEstimate = new Double(tokenize_payload[3]);
							String clientTime = dateFormat.format(new Date());
							/* sanity check */
							if (!GUI.gameRoundsStates[estimateForRound] || !GUI.gameStagesStates[estimateForStage]) {
								log.println("Sanity check failed: Client " + hex +" submitted estimate either for a finished round or a finished stage.");
								response.getWriter().print("roundfinished");
							}
							else {
								response.getWriter().print("ok");
								/*update the round info for this client*/
								ClientLog oldClient = GUI.clients.get(hex);
								oldClient.updateRound(clientTime, clientEstimate, estimateForRound);
								GUI.updateGUITable(oldClient,GUI.ROUND_END);
							}

						}
						catch (NumberFormatException e) {
							response.getWriter().print("malformed request " + payload);
						}
					}
					else if (payload.indexOf("ready") != -1 ) {
						//ready for the next stage
						String[] tokenize_payload = payload.split("\\s");
						try {							
							Integer readyForStage = new Integer(tokenize_payload[1]);							
							String clientTime = dateFormat.format(new Date());
							/* sanity check */
							/* must be ready for a valid game stage AND that stage must be disabled at the moment*/
							if (readyForStage < GUI.gameStages && !GUI.gameStagesStates[readyForStage]) {
								response.getWriter().print("ok");
								ClientLog oldClient = GUI.clients.get(hex);								
								oldClient.stagesEndTime.add(clientTime);
								GUI.updateGUITable(oldClient,GUI.STAGE_END);

							}
							else 
								response.getWriter().print("insane");

						}
						catch (NumberFormatException e) {
							response.getWriter().print("malformed request " + payload);
						}
					}
					else if (payload.indexOf("doneinstructions") != -1) {
						GUI.activeClients++;
						String clientTime = dateFormat.format(new Date());
						ClientLog client = GUI.clients.get(hex);
						client.reg_end = clientTime;			
						client.validClient = true;
						GUI.updateGUITable(client,GUI.REG_END);
						response.getWriter().print("ok");
					}		
					else if (payload.indexOf("finito") != -1) {
						String clientTime = dateFormat.format(new Date());
						ClientLog client = GUI.clients.get(hex);
						client.stagesEndTime.add(clientTime);
						GUI.updateGUITable(client,GUI.STAGE_END);
						response.getWriter().print("ok");
					}

					else {response.getWriter().print("unknown_request");					}
				}
				baseRequest.setHandled(true);			
			}
		}
	}

}
