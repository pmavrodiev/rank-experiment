package pm;




import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.IOException;
import java.io.PipedInputStream;
import java.io.PipedOutputStream;
import java.io.PrintStream;

import java.util.ArrayList;
import java.util.Collection;


import java.util.HashMap;




import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSplitPane;
import javax.swing.JTable;
import javax.swing.JTextArea;

import javax.swing.UIManager;
import javax.swing.table.DefaultTableModel;






public class GUI extends JFrame {

	private static final long serialVersionUID = 1L;
	/*game related stuff*/
	public static final double truth = -35.0; //in degrees
	/*the mean of the normal distribution that generates the initial guesses is fixed to +90*/
	public static final double mu = 90.0;
	public static final double init_colllective_err = Math.pow(truth-mu,2.0); 
	public static final double init_diversity = 0.0025;
	public static final int gameRounds = 5;
	public static int next_round = 0;
	public static final int ANNOUNCE=0;	
	public static final int RE_ANNOUNCE=1;
	public static final int REG_END=2;
	public static final int ROUND_BEGIN=3;
	public static final int ROUND_ESTIMATE=4;
	public static final int ROUND_END=5;
	public static boolean inprogress=false;
	public static boolean finished = false;
	/*maps initial estimate to rank*/
	//public static HashMap<Double, Integer> initialEstimates;
	/*maps current estimate to rank*/
	public static HashMap<Integer, Integer> currentRanks; //id->rank
	public static ArrayList<Double> currentEstimates;
	//stores the initial states (=false) of each game round
	public static boolean[] gameRoundsStates;	
	public static HashMap<String,ClientLog> clients;
	/*swing stuff*/
	private static JPanel jPanel0;
	private static JButton startstop;
	private static JButton nextRound;
	private static JScrollPane scrollpane;
	private static JTable logtable;
	public static JTextArea console_output;
	private static JScrollPane console_pane;
	private static JSplitPane split_pane;
	/*misc stuff*/
	private static final String PREFERRED_LOOK_AND_FEEL = "javax.swing.plaf.metal.MetalLookAndFeel";
	private static MyServer myServer;
	private static ReaderThread pOut;
	private static ReaderThread pErr;
	static PipedInputStream piOut = new PipedInputStream();
	static PipedInputStream piErr = new PipedInputStream();
	static PipedOutputStream poOut;
	static PipedOutputStream poErr;

	public GUI(final MyServer myServer) {
		GUI.myServer = myServer;
		/*game related stuff*/
		clients = new HashMap<String,ClientLog>();
		gameRoundsStates = new boolean[gameRounds];
		for (int i=0; i<gameRounds;i++) gameRoundsStates[i]=false;
		//clients = new Map<String,ClientLog>();
		initComponents();
		Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
			@Override
			public void run() {
				if(myServer.isStarted()) {
					try {
						myServer.stop();
					} catch (Exception exception) {
						exception.printStackTrace();
					}
				}
			}
		},"Stop Jetty Hook"));		
		/*init logging*/
	}

	private void initComponents() {
		setLayout(new GridBagLayout());
		this.setSize(897, 447);
		GridBagConstraints c = new GridBagConstraints();
		c.fill = GridBagConstraints.BOTH;
		c.weightx = 0; c.weighty = 0;
		c.gridx = 0; c.gridy = 0;
		c.anchor = GridBagConstraints.NORTHWEST;
		//the panel
		this.add(getJPanel0(),c);
		//the scroll pane
		c.weightx = 1; c.weighty=1;
		c.gridx = 0; c.gridy = 1;c.anchor = GridBagConstraints.NORTHWEST;
		this.add(getJSplitPane(),c);		
	}


	public static JSplitPane getJSplitPane() {
		if (split_pane == null) {
			split_pane = new JSplitPane(JSplitPane.VERTICAL_SPLIT,getScrollPane(),getConsolePane());
			split_pane.setDividerLocation(150);
		}
		return split_pane;
	}


	public static JScrollPane getConsolePane() {
		if (console_pane == null) {
			console_pane = new JScrollPane(getConsoleOutput());			
		}
		return console_pane;
	}

	public static JTextArea getConsoleOutput() {
		if (console_output == null) {
			console_output = new JTextArea();
			console_output.setEditable(false);			
		}
		return console_output;
	}


	public static JButton getStartStopButton() {
		if (startstop == null) {
			startstop = new JButton("Start");
			startstop.addActionListener(new ServerStartStopActionListener(myServer));
		}
		return startstop;
	}

	public static JButton getNextRoundButton() {
		if (nextRound == null) {
			nextRound = new JButton("Begin Round 1");
			nextRound.addActionListener(new ActionListener() {				
				@Override
				public void actionPerformed(ActionEvent e) {
					inprogress = true;				
					if (next_round < gameRounds) {			
						if (next_round > 0) //because initially it's 0
							gameRoundsStates[next_round-1] = false;
						if (next_round == 0) {
							/*generate initial ranks*/						
							currentRanks = new HashMap<Integer, Integer>(GUI.clients.size());							
							currentEstimates = new ArrayList<Double>(GUI.clients.size());
							for (int i=0; i<GUI.clients.size();i++) {
								currentRanks.put(i, -1);
								currentEstimates.add(WrappedGaussian.phi_wrapped(mu, Math.sqrt(init_diversity))); 
								
							}	

						} 
						else{ //not the very first round
							/*TODO THIS IS THE PROBLEM, THE CAST TO ARRAYLIST*/
							/*populate currentEstimates with data from the last round*/
							//cycle through all clients
							Collection<ClientLog> cc = clients.values();
							ArrayList<ClientLog> l = (ArrayList<ClientLog>) cc;
							for (int i=0; i<cc.size();i++) {								
								ClientLog oldClient = l.get(i);
								currentEstimates.set(i, oldClient.getRound(next_round-1).getEstimateAsDouble());
							}

						}
						computeRanks();	
						gameRoundsStates[next_round++] = true;
						if (next_round == gameRounds) {
							nextRound.setEnabled(false);
							finished=true;
						}
						else {
							((JButton) e.getSource()).setText("Begin Round " + (next_round+1));
							if (next_round == (gameRounds-1))
								((JButton) e.getSource()).setText("Begin Last Round " + (next_round+1));
						}

					}
				}
			}
					);
			//startstop.addActionListener(new ServerStartStopActionListener(myServer));
		}
		return nextRound;
	}

	private JPanel getJPanel0() {
		if (jPanel0 == null) {
			jPanel0 = new JPanel();
			jPanel0.setLayout(new GridBagLayout());
			GridBagConstraints c = new GridBagConstraints();
			c.gridx = 0; c.gridy = 0; c.anchor = GridBagConstraints.NORTHWEST;
			jPanel0.add(getStartStopButton(),c); 	
			c.gridx = 1; c.gridy = 0;c.anchor = GridBagConstraints.NORTHEAST;
			jPanel0.add(getNextRoundButton(),c); 
		}
		return jPanel0;
	}

	private static JScrollPane getScrollPane() {
		if (scrollpane == null) {
			scrollpane = new JScrollPane(getLogTable());
			getLogTable().setFillsViewportHeight(true);

		}
		return scrollpane;
	}

	public static JTable getLogTable() {
		if (logtable == null) {

			DefaultTableModel dataModel = new 	DefaultTableModel();
			logtable = new JTable(dataModel);
			/*create columns*/
			dataModel.addColumn("Client");dataModel.addColumn("RegBegin");dataModel.addColumn("RegEnd");	

			for (int i=0; i<gameRounds; i++) {
				String c = "Round_" + (i+1) + "_BEGIN"; String c2 = "Estimate"; String c3 = "Round_" + (i+1) + "_END";
				dataModel.addColumn(c);	dataModel.addColumn(c2);dataModel.addColumn(c3);				
			}
			for (int i=0; i<(3+3*gameRounds); i++) 
				logtable.getColumnModel().getColumn(i).setPreferredWidth(120);

			logtable.setAutoResizeMode(JTable.AUTO_RESIZE_OFF );  
		}
		return logtable;
	}




	private static void installLnF() {
		try {
			String lnfClassname = PREFERRED_LOOK_AND_FEEL;
			UIManager.setLookAndFeel(lnfClassname);
		} catch (Exception e) {
			System.err.println("Cannot install " + PREFERRED_LOOK_AND_FEEL
					+ " on this platform:" + e.getMessage());
		}
	}

	/**
	 * Main entry of the class.
	 * @throws Exception 
	 */
	public static void main(String[] args) throws Exception {
		installLnF();		
		myServer = new MyServer();
		GUI frame = new GUI(myServer);
		initOutputRedirect();		
		frame.setDefaultCloseOperation(GUI.EXIT_ON_CLOSE);
		frame.setTitle("Server Control Monitor");
		frame.getContentPane().setPreferredSize(frame.getSize());
		frame.pack();
		frame.setLocationRelativeTo(null);
		frame.setVisible(true);
		/*
		SwingUtilities.invokeLater(new Runnable() {
			@Override
			public void run() {					   
				GUI frame = new GUI(myServer);
				pOut = frame.new ReaderThread(piOut);
				pErr = frame.new ReaderThread(piErr);
				frame.setDefaultCloseOperation(GUI.EXIT_ON_CLOSE);
				frame.setTitle("Server Control Monitor");
				frame.getContentPane().setPreferredSize(frame.getSize());
				frame.pack();
				frame.setLocationRelativeTo(null);
				frame.setVisible(true);
				pOut.start();
				pErr.start();
			}
		});
		 */
	}

	public static void initOutputRedirect() {
		/*re-direct the default output and error streams*/
		// Set up System.out
		try {
			poOut = new PipedOutputStream(piOut);
			System.setOut(new PrintStream(poOut, true));	
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		// Set up System.err	
		try {
			poErr = new PipedOutputStream(piErr);
			System.setErr(new PrintStream(poErr, true));
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		pOut = new ReaderThread(piOut);
		pErr = new ReaderThread(piErr);
		pOut.start();
		pErr.start();
	}

	public static void stopOutputRedirect() throws IOException {
		poOut.flush();
		poOut.close();
		poErr.flush();
		poErr.close();
		piOut.close();
		piErr.close();

	}

	public static void updateGUITable(ClientLog newClient,int state) {
		DefaultTableModel model = (DefaultTableModel) getLogTable().getModel();
		if (state == ANNOUNCE) {
			model.addRow(new Object[] {newClient.client_ip,newClient.reg_begin});
		}
		else if (state == RE_ANNOUNCE) {
			/*The newClient parameter is not really new in this case. 
			 *It is the existing client who is reannouncing himself*/
			int rowIdx = newClient.id;
			int colIdx = 1; //REG_BEGIN
			model.setValueAt((Object) newClient.reg_begin, rowIdx, colIdx);
		}
		else if (state == REG_END) {
			int rowIdx = newClient.id;
			int colIdx = 2; //REG_END
			model.setValueAt((Object) newClient.reg_end, rowIdx, colIdx);
		}
		else if (state == ROUND_BEGIN) {
			int rowIdx = newClient.id;
			int colIdx = 3 + 3*newClient.currentRound;			
			model.setValueAt((Object) newClient.getRound(newClient.currentRound).getRound_begin(),
					rowIdx, colIdx);

		}
		else if (state == ROUND_ESTIMATE || state == ROUND_END) {
			int rowIdx = newClient.id;
			int colIdx = 4 + 3*newClient.currentRound;
			int colIdx2 = 5 + 3*newClient.currentRound;

			model.setValueAt((Object) newClient.getRound(newClient.currentRound).getEstimate(), 
					rowIdx, colIdx);
			model.setValueAt((Object) newClient.getRound(newClient.currentRound).getRound_end(), 
					rowIdx, colIdx2);
		}

	}

	public static void computeRanks() {
		//maps estimate to client_id
		HashMap<Double, Integer> tmp = new HashMap<Double,Integer>(clients.size());
		for (int i=0; i<clients.size(); i++)
			tmp.put(currentEstimates.get(i),i);		    

		java.util.Collections.sort(currentEstimates);
		int ctr = 1;
		for (int i=currentEstimates.size()-1; i>=0; i--) 
			currentRanks.put(tmp.get(currentEstimates.get(i)), ctr++);
	}





}
