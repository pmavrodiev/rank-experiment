package pm;

import java.awt.Component;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PipedInputStream;
import java.io.PipedOutputStream;
import java.io.PrintStream;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.HashMap;


import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSplitPane;
import javax.swing.JTabbedPane;
import javax.swing.JTable;
import javax.swing.JTextArea;
import javax.swing.UIManager;
import javax.swing.table.DefaultTableModel;
import org.apache.commons.collections.map.MultiValueMap;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;

import com.itextpdf.text.Anchor;
import com.itextpdf.text.BadElementException;
import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Chapter;
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
//import com.itextpdf.text.List;
import com.itextpdf.text.ListItem;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.Section;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;

public class GUI extends JFrame {

	private static final long serialVersionUID = 1L;
	/* game related stuff */
	public static final double truth = 0.0; // in degrees
	/*
	 * the mean of the normal distribution that generates the initial guesses is
	 * fixed to +90
	 */
	/*in terms of CE and Diversity the 5 stages have
	 * Stage 1: low CE, low Div.
	 * Stage 2: low CE, high Div.
	 * Stage 3: medium CE, low Div.
	 * Stage 4: high CE, low Div.
	 * Stage 5: high CE, high Div.
	 * Stage 6:
	 * Stage 7:
	 * Stage 8: */
	public static double[] mu = {Math.PI/9,Math.PI/9,Math.PI/4.5,Math.PI/4.5,Math.PI/9,Math.PI/9,Math.PI/4.5,Math.PI/4.5}; //in degrees: [20,20,40,40,20,20,40,40]
	public static double [] init_diversity = {0.0025,0.0025,0.0025,0.0025,1,2.25,1,2.25}; //variance
	public static final int gameRounds = 1;
	public static final int gameStages = 1;
	public static int completedRounds = 0;
	public static int completedStages = 0;
	public static int next_stage = 0;
	public static int next_round = 0;
	/* flags for the log table */
	public static final int ANNOUNCE = 0;
	public static final int RE_ANNOUNCE = 1;
	public static final int REG_END = 2;
	public static final int ROUND_BEGIN = 3;
	public static final int ROUND_ESTIMATE = 4;
	public static final int ROUND_END = 5;
	public static final int RANK = 6;
	public static final int INIT_ESTIMATE = 7;
	public static final int USERNAME = 8;
	public static final int STAGE_END = 9;
	/* **************************** */
	public static boolean inprogress = false;
	public static boolean finished = false;
	public static HashMap<Integer, Integer> currentRanks; // client id->rank
	public static ArrayList<Double> currentEstimates;
	// stores the initial states (=false) of each game round
	public static boolean[] gameRoundsStates;
	// stores the initial states (=false) of each game stage
	public static boolean[] gameStagesStates;
	public static LinkedHashMap<String, ClientLog> clients;
	/* active clients */
	public static int activeClients;
	/* number of connected clients in the beginning*/
	public static int totalPlayers;
	/* swing stuff */
	private static JPanel jPanel0;
	private static JButton startstop;
	private static JButton nextRound;
	private static JButton nextStage;
	private static JButton exportData;
	private static JButton calculatePayoffs;
	private static JScrollPane[] scrollpane;
	private static JTable[] logtable;
	public static JTextArea console_output;
	private static JScrollPane console_pane;
	private static JSplitPane split_pane;
	private static JTabbedPane tabbed_pane;
	private static JPanel init_cond_panel;
	/* misc stuff */
	private static final String PREFERRED_LOOK_AND_FEEL = "javax.swing.plaf.metal.MetalLookAndFeel";
	private static MyServer myServer;
	private static ReaderThread pOut;
	private static ReaderThread pErr;
	static PipedInputStream piOut = new PipedInputStream();
	static PipedInputStream piErr = new PipedInputStream();
	static PipedOutputStream poOut;
	static PipedOutputStream poErr;

	public static int delme = 0;	
	
	public GUI(final MyServer myServer) {
		GUI.myServer = myServer;
		/* game related stuff */
		clients = new LinkedHashMap<String, ClientLog>();
		activeClients = 0;
		totalPlayers = 0;
		gameRoundsStates = new boolean[gameRounds + 1]; // +1 for the final
		// dummy round, i.e.
		// similar to the .end()
		// iterator in stl
		// containers
		gameStagesStates = new boolean[gameStages + 1];
		for (int i = 0; i <= gameRounds; i++)
			gameRoundsStates[i] = false;
		for (int i = 0; i <= gameStages; i++)
			gameStagesStates[i] = false;
		scrollpane = new JScrollPane[gameStages];
		logtable = new JTable[gameStages];
		initComponents();
		Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
			@Override
			public void run() {
				if (myServer.isStarted()) {
					try {
						myServer.stop();
					} catch (Exception exception) {
						exception.printStackTrace();
					}
				}
			}
		}, "Stop Jetty Hook"));
		/* init logging */
	}	
	private void initComponents() {
		setLayout(new GridBagLayout());
		this.setSize(897, 447);
		GridBagConstraints c = new GridBagConstraints();
		c.fill = GridBagConstraints.BOTH;
		c.weightx = 0;
		c.weighty = 0;
		c.gridx = 0;
		c.gridy = 0;
		c.anchor = GridBagConstraints.NORTHWEST;
		// the panel
		this.add(getJPanel0(), c);
		// the scroll pane
		c.weightx = 1;
		c.weighty = 1;
		c.gridx = 0;
		c.gridy = 1;
		c.anchor = GridBagConstraints.NORTHWEST;
		this.add(getJSplitPane(), c);
	}

	public static JSplitPane getJSplitPane() {
		if (split_pane == null) {
			split_pane = new JSplitPane(JSplitPane.VERTICAL_SPLIT,
					getTabbedPane(), getConsolePane());
			// split_pane = new
			// JSplitPane(JSplitPane.VERTICAL_SPLIT,getScrollPane(),getConsolePane());
			split_pane.setDividerLocation(150);
		}
		return split_pane;
	}

	public static JTabbedPane getTabbedPane() {
		if (tabbed_pane == null) {
			tabbed_pane = new JTabbedPane();
			/* add the tab with the Initial Conditions. */
			tabbed_pane.addTab("Initial Conditions", getInitialConditionsPanel());
			/* add the "Stages" tabs */
			for (int i = 1; i <= gameStages; i++) {
				tabbed_pane.addTab("Stage " + i, getScrollPane(i - 1));
				tabbed_pane.setEnabledAt(i, false); // disable all but the first
				// tab
			}

		}
		return tabbed_pane;
	}

	public static JPanel getInitialConditionsPanel() {

		if (init_cond_panel == null) {
			init_cond_panel = new JPanel();
			LinearJSlider mean = new LinearJSlider(0.0,360.0,"mean[degrees]");			
			init_cond_panel.add(mean);
			LinearJSlider variance = new LinearJSlider(0.0,0.5,"variance");
			init_cond_panel.add(variance);
		}
		return init_cond_panel;
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
			startstop.addActionListener(new ServerStartStopActionListener(
					myServer));
		}
		return startstop;
	}

	public static JButton getExportButton() {
		if (exportData == null) {
			exportData = new JButton("Export Data");
			exportData.addActionListener(new ActionListener() {
				@Override
				public void actionPerformed(ActionEvent e) {			
					/*year_day_month_hour_minute*/
					String time = (new SimpleDateFormat("yyyy_dd_MM_HH_mm")).format(new Date());
					try {
						Class.forName("org.sqlite.JDBC");
					} catch (ClassNotFoundException e1) {
						e1.printStackTrace();
					}
					try {
						Connection conn = DriverManager.getConnection("jdbc:sqlite:"+time+".db");
						Statement stat = conn.createStatement();
						//stat.executeUpdate("drop table if exists people;");
						/*build the tables*/
						for (int j=0; j<gameStages; j++) {
							DefaultTableModel model = (DefaultTableModel) getLogTable(j).getModel();
							String tableName = "export_"+time+"_"+j;
							String createTableStr = "create table "+tableName+" (";
							String insertStr = "(";
							for (int i=0; i<model.getColumnCount(); i++) {
								createTableStr = createTableStr + model.getColumnName(i);
								insertStr = insertStr+"?";
								if (i != model.getColumnCount()-1) {
									createTableStr = createTableStr + ",";
									insertStr = insertStr+",";
								}

							}
							/*the last two columns*/
							createTableStr = createTableStr + ", mu, sigma);";
							insertStr = insertStr + ",?,?)";
							stat.executeUpdate(createTableStr);
							PreparedStatement prep = conn.prepareStatement("insert into "+ tableName+" values "+insertStr+";");
							for (int i=0; i<model.getRowCount(); i++) {
								for (int k=0; k<model.getColumnCount(); k++) {
									Object obj = model.getValueAt(i, k);
									if (obj != null)
										prep.setString(k+1,obj.toString());
									else
										prep.setString(k+1, "");
								}
								/*the last two columns*/
								prep.setDouble(model.getColumnCount()+1,mu[j]);
								prep.setDouble(model.getColumnCount()+2,init_diversity[j]);
								prep.addBatch();
							}
							conn.setAutoCommit(false);
							prep.executeBatch();
							conn.setAutoCommit(true);
						}
						conn.close();
					}
					catch (SQLException sqle) {
						sqle.printStackTrace();
					}

				}
			});

		}
		return exportData;
	}
	private static void addEmptyLine(Paragraph paragraph, int number) {
		  for (int i = 0; i < number; i++) {
		    paragraph.add(new Paragraph(" "));
		  }
    }
	private static JButton getCalculatePayoffsButton() {
		if (calculatePayoffs==null) {
			calculatePayoffs = new JButton("Calculate Payoffs");
			calculatePayoffs.addActionListener(new ActionListener() {
				@Override
				public void actionPerformed(ActionEvent e){
				    Double[] payoffs_per_stage = {10.6,8.1,5.0,3.8,3.8,3.8,3.1,3.1,3.1,1.9,1.9,1.9,1.9,1.2,
				    		1.2,1.2,1.2,0.6,0.6,0.6};
					try {
					//System.out.println(completedStages);
					String filename = (new SimpleDateFormat("yyyy_dd_MM_HH_mm")).format(new Date()) + "-payoffs.pdf";
					final Font boldFont = new Font(Font.FontFamily.TIMES_ROMAN, 18,Font.BOLD);
					final Font smallBold = new Font(Font.FontFamily.TIMES_ROMAN, 12,Font.BOLD);
					Document document = new Document();				    
					PdfWriter.getInstance(document, new FileOutputStream(filename));
					document.open();
					document.addTitle("Payoffs for the rank experiment");
					Paragraph preface = new Paragraph();
				    // We add one empty line
				    addEmptyLine(preface, 1);
				    // Lets write a big header
				    preface.add(new Paragraph("Payoffs for the rank experiment", boldFont));

				    addEmptyLine(preface, 1);
				    // Will create: Report generated by: _name, _date
				    preface.add(new Paragraph("Report generated by: " + System.getProperty("user.name") + ", " + 
				    						   new Date(),smallBold));
				    addEmptyLine(preface, 3);
				    document.add(preface);					
					/*generate the payoff table*/
					PdfPTable table = new PdfPTable(completedStages+3);
					PdfPCell c1 = new PdfPCell(new Phrase("PC"));
				    c1.setHorizontalAlignment(Element.ALIGN_CENTER);
				    table.addCell(c1);
					for (int i=0; i<completedStages; i++) {
						c1 = new PdfPCell(new Phrase("Stage "+(i+1)));
						c1.setHorizontalAlignment(Element.ALIGN_CENTER);
					    table.addCell(c1);
					}
					c1 = new PdfPCell(new Phrase("Show up"));
					c1.setHorizontalAlignment(Element.ALIGN_CENTER);
				    table.addCell(c1);
					c1 = new PdfPCell(new Phrase("Total"));
					c1.setHorizontalAlignment(Element.ALIGN_CENTER);
				    table.addCell(c1);
				    table.setHeaderRows(1);
				    DefaultTableModel model = (DefaultTableModel) getLogTable(0).getModel();
				    for (int i=0; i<model.getRowCount(); i++) {
				    	String IP = model.getValueAt(i,0).toString();
				    	String[] tokenize_ip = IP.split("\\.");
				    	Integer PCnumber = new Integer(tokenize_ip[3]);
				    	PCnumber -= 140; //subtract 140 from the IP to get the PC number
				    	table.addCell(PCnumber.toString()); //the machine (PC) number
				    	Double total_payoff_i = 0.0;
				    	for (int j=0; j<completedStages; j++) {
				    		DefaultTableModel m = (DefaultTableModel) getLogTable(j).getModel();
				    		Integer final_rank = new Integer(m.getValueAt(i, m.getColumnCount()-1).toString());
				    		Double payoff = (final_rank <= 20) ? payoffs_per_stage[final_rank-1] : 0.0;
				    		total_payoff_i += payoff;
				    		table.addCell(payoff.toString());
				    	}
				    	table.addCell("10 CHF");
				    	total_payoff_i += 10;
				    	long total_payoff_rounded = Math.round(total_payoff_i);
				    	String result = total_payoff_i + " ~ "+total_payoff_rounded + " CHF";
				    	table.addCell(result);
				    }				  
					/* *********************** */
				    document.add(table);
					
					document.close();
					} catch (FileNotFoundException e1) {					
						e1.printStackTrace();
					} catch (DocumentException e1) {						// 
						e1.printStackTrace();
					}
				    
				}
			});

		}
		return calculatePayoffs;
	}
	public static JButton getNextStageButton() {
		if (nextStage == null) {
			nextStage = new JButton("Begin Stage " + (next_stage + 1));
			for (int i = 0; i <= gameRounds; i++)
				gameRoundsStates[i] = false;
			nextStage.setEnabled(false);
			nextStage.addActionListener(new ActionListener() {
				@Override
				public void actionPerformed(ActionEvent e) {
					/*invalidate the last round of the previous stage*/
					gameRoundsStates[gameRounds]=false; //disable the last round of the current stage
					// invalidate the previous stage, taking care of the initial case
					if (next_stage == 0)
						gameStagesStates[next_stage] = false;
					else {
						gameStagesStates[next_stage-1] = false;
						DefaultTableModel model = (DefaultTableModel) getLogTable(next_stage-1).getModel();
						/*check if all clients have finished the stage*/
						for (int i=0; i<model.getRowCount(); i++) {
							ClientLog client = clients.get(model.getValueAt(i,1));
							client.personalOffset = UniformDistribution.pi_uniform();							
							if (model.getValueAt(i, model.getColumnCount()-2) == null) {
								if (client.validClient) { //if check fails, this client has already been invalidated
									activeClients--; // this guys is out
									client.inValidate();
								}
							}
						}

					}


					// enable the Begin Next Round button in the beginning
					if (!nextRound.isEnabled())
						nextRound.setEnabled(true);
					((JButton) e.getSource()).setEnabled(false); // disable until the current stage finished
					GUI.getTabbedPane().setEnabledAt(next_stage + 1, true);
					/*
					 * copy the static client info (from IP to Initial Estimate) to the new tab,
					 * but only if it's not the last stage of the game */

					if (next_stage-1 >=0 && next_stage < GUI.gameStages) {
						DefaultTableModel oldModel = (DefaultTableModel) getLogTable(next_stage-1).getModel();
						DefaultTableModel newModel = (DefaultTableModel) getLogTable(next_stage).getModel();
						int rowCount = oldModel.getRowCount();
						for (int i = 0; i < rowCount; i++) {
							ClientLog client = clients.get(oldModel.getValueAt(i, 1));
							Double clientOffset = client.personalOffset;
							if (client.validClient) {
								newModel.addRow(new Object[] {
										oldModel.getValueAt(i, 0),
										oldModel.getValueAt(i, 1),
										oldModel.getValueAt(i, 2),
										clientOffset,
										null,
										null,
										null,
										null});
							}
							else
								newModel.addRow(new Object[] {
										oldModel.getValueAt(i, 0),
										oldModel.getValueAt(i, 1),
										oldModel.getValueAt(i, 2),
										null,
										null,
										null,
										null,
										null});

						}

					}
					gameStagesStates[next_stage++] = true;//enable the next stage

				} // end actionPerformed
			});

		}
		return nextStage;
	}

	public static JButton getNextRoundButton() {
		if (nextRound == null) {
			nextRound = new JButton("Begin Round 1");
			nextRound.setEnabled(false);
			nextRound.addActionListener(new ActionListener() {
				@Override
				public void actionPerformed(ActionEvent e) {
					inprogress = true;
					if (next_round <= gameRounds) {
						if (next_round == 0) {
							/* generate initial ranks */
							currentRanks = new HashMap<Integer, Integer>(GUI.clients.size());
							currentEstimates = new ArrayList<Double>(GUI.clients.size());
							Set<Map.Entry<String, ClientLog>> s = clients.entrySet();
							Iterator<Map.Entry<String, ClientLog>> itr = s.iterator();
							int i = 0;
							while (itr.hasNext()) {
								Map.Entry<String, ClientLog> el = itr.next();
								ClientLog oldClient = el.getValue();
								currentRanks.put(i, -1);
								if (oldClient.validClient)
									currentEstimates.add(WrappedGaussian.phi_wrapped(mu[next_stage-1],
											Math.sqrt(init_diversity[next_stage-1]))); //current stage
								else
									currentEstimates.add(-1.0);
							}							
							updateGUITable(null, INIT_ESTIMATE);
						} 
						else { // not the very first round
							Object[] options = {"Continue","Wait"};
							int n = 0;
							if (GUI.totalPlayers > 0)
								n = JOptionPane.showOptionDialog((Component) getConsolePane(),"Wait for other players?","Are you sure?",
																JOptionPane.YES_NO_OPTION,
																JOptionPane.QUESTION_MESSAGE,
																null,
																options,
																options[1]);
							
							
							if (n == 1) return;
							/*
							 * 	populate currentEstimates with data from the last
							 * round
							 */
							gameRoundsStates[next_round - 1] = false; // invalidate
							// the previous round
							Set<Map.Entry<String, ClientLog>> s = clients.entrySet();
							Iterator<Map.Entry<String, ClientLog>> itr = s.iterator();
							int i = 0;
							while (itr.hasNext()) {
								Map.Entry<String, ClientLog> el = itr.next();
								ClientLog oldClient = el.getValue();
								/*
								 * Can we get the estimate of oldClient for this
								 * round?If the client has submitted an estimate
								 * for next_round-2, but disconnected prior to
								 * sendinga "rank" request for next_round-1 then
								 * no gameRound entity would be initialized,
								 * hence the call
								 * oldClient.getRound(next_round-1) will
								 * segfault.
								 */
								if (oldClient.getValidRound(next_round - 1) && oldClient.validClient) {
									currentEstimates.set(i,oldClient.getRound(next_round - 1).getInternalEstimateAsDouble());
								} else {
									if (currentEstimates.get(i) != -1.0) { // client
										// not already invalidated
										GUI.activeClients--; // this guys is out
										oldClient.inValidate();
										currentEstimates.set(i, -1.0); // set
										// some gatekeeping value
									}
								}
								i++;
							} //end while							
						} //end else
						computeRanks();
						gameRoundsStates[next_round++] = true;
						updateGUITable(null, RANK);
						GUI.totalPlayers = GUI.activeClients;
						if (next_round == gameRounds) {
							((JButton) e.getSource()).setText("End Stage "+ next_stage);							
						} else if (next_round == (gameRounds + 1)) {
							prepareNextStage();							
						} else {
							((JButton) e.getSource()).setText("Begin Round "+ (next_round + 1));							
							if (next_round == (gameRounds - 1))
								((JButton) e.getSource())
								.setText("Begin Last Round "+ (next_round + 1));
						}

					} // end if (next_round<gameRounds
				}
			});

		}
		return nextRound;
	}

	private static void prepareNextStage() {		
		completedStages++;
		/* sort out the buttons first */
		if (next_stage < gameStages) {
			nextStage.setEnabled(true);
			nextStage.setText("Begin Stage " + (next_stage + 1));
			nextRound.setText("Begin Round 1");
			nextRound.setEnabled(false);
			next_round = 0;
		}
		else			
			finished = true;

	}

	private JPanel getJPanel0() {
		if (jPanel0 == null) {
			jPanel0 = new JPanel();
			jPanel0.setLayout(new GridBagLayout());
			GridBagConstraints c = new GridBagConstraints();
			c.gridx = 0;
			c.gridy = 0;
			c.anchor = GridBagConstraints.NORTHWEST;
			jPanel0.add(getStartStopButton(), c);
			c.gridx = 1;
			c.gridy = 0;
			c.anchor = GridBagConstraints.NORTHEAST;
			jPanel0.add(getNextRoundButton(), c);
			c.gridx = 2;
			c.gridy = 0;
			c.anchor = GridBagConstraints.NORTHEAST;
			jPanel0.add(getNextStageButton(), c);
			c.gridx = 3;
			c.gridy = 0;
			c.anchor = GridBagConstraints.NORTH;
			jPanel0.add(getExportButton(), c);
			c.gridx = 4;
			c.gridy = 0;
			c.anchor = GridBagConstraints.NORTH;
			jPanel0.add(getCalculatePayoffsButton(), c);
		}
		return jPanel0;
	}

	private static JScrollPane getScrollPane(int whichPane) {
		if (scrollpane[whichPane] == null) {
			scrollpane[whichPane] = new JScrollPane(getLogTable(whichPane));
			getLogTable(whichPane).setFillsViewportHeight(true);
		}
		return scrollpane[whichPane];
	}

	public static JTable getLogTable(int whichTable) {
		if (logtable[whichTable] == null) {

			DefaultTableModel dataModel = new DefaultTableModel();
			logtable[whichTable] = new JTable(dataModel);
			/* create columns */
			dataModel.addColumn("IP");
			dataModel.addColumn("Hex");
			dataModel.addColumn("Username");
			dataModel.addColumn("Offset");
			dataModel.addColumn("RegBegin");
			dataModel.addColumn("RegEnd");
			dataModel.addColumn("Initial_Rank");
			dataModel.addColumn("Initial_Estimate");

			for (int i = 0; i < gameRounds; i++) {
				String c = "Round_" + (i + 1) + "_BEGIN";
				String c2 = "Estimate_"+(i+1);
				String c3 = "Rank_"+(i+1);
				String c4 = "Round_" + (i + 1) + "_END";
				dataModel.addColumn(c);
				dataModel.addColumn(c2);
				dataModel.addColumn(c3);
				dataModel.addColumn(c4);
			}
			dataModel.addColumn("STAGE_END");
			dataModel.addColumn("FINAL_RANK");
			for (int i = 0; i < dataModel.getColumnCount(); i++)
				logtable[whichTable].getColumnModel().getColumn(i)
				.setPreferredWidth(120);

			logtable[whichTable].setAutoResizeMode(JTable.AUTO_RESIZE_OFF);
		}
		return logtable[whichTable];
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
	 * 
	 * @throws Exception
	 */
	public static void main(String[] args) throws Exception {
		installLnF();
		myServer = new MyServer();
		GUI frame = new GUI(myServer);
		//initOutputRedirect();
		frame.setDefaultCloseOperation(GUI.EXIT_ON_CLOSE);
		frame.setTitle("Server Control Monitor");
		frame.getContentPane().setPreferredSize(frame.getSize());
		frame.pack();
		frame.setLocationRelativeTo(null);
		frame.setVisible(true);
	}

	public static void initOutputRedirect() {
		/* re-direct the default output and error streams */
		// Set up System.out
		
		  try { poOut = new PipedOutputStream(piOut); System.setOut(new
		  PrintStream(poOut, true)); } catch (IOException e) {
		  
		  e.printStackTrace(); } // Set up System.err 
		  try { poErr = new PipedOutputStream(piErr); System.setErr(new PrintStream(poErr,
		  true)); } catch (IOException e) {
		  
		  e.printStackTrace(); } pOut = new ReaderThread(piOut); pErr = new
		  ReaderThread(piErr); pOut.start(); pErr.start();
		 
	}

	public static void stopOutputRedirect() throws IOException {
		poOut.flush();
		poOut.close();
		poErr.flush();
		poErr.close();
		piOut.close();
		piErr.close();

	}

	public static void updateGUITable(ClientLog newClient, int state) {
		/*always take next_stage-1 in this function, because we need the current stage*/
		if (next_stage-1 >= gameStages || next_stage-1 < 0)
			return;
		DefaultTableModel model = (DefaultTableModel) getLogTable(next_stage-1).getModel();
		if (state == ANNOUNCE) {
			model.addRow(new Object[] { newClient.client_ip, newClient.hex,
					null, newClient.personalOffset, newClient.reg_begin });
		} else if (state == RE_ANNOUNCE) {
			/*
			 * The newClient parameter is not really new in this case.It is the
			 * existing client who is reannouncing himself
			 */
			int rowIdx = newClient.id;
			int colIdx = 4; // REG_BEGIN
			model.setValueAt((Object) newClient.reg_begin, rowIdx, colIdx);
		} else if (state == REG_END) {
			int rowIdx = newClient.id;
			int colIdx = 5; // REG_END
			model.setValueAt((Object) newClient.reg_end, rowIdx, colIdx);
			GUI.totalPlayers = GUI.activeClients;
		} else if (state == ROUND_BEGIN) {
			int rowIdx = newClient.id;
			int colIdx = 8 + 4 * newClient.currentRound;
			model.setValueAt((Object) newClient
					.getRound(newClient.currentRound).getRound_begin(), rowIdx,
					colIdx);

		} else if (state == ROUND_ESTIMATE || state == ROUND_END) {
			int rowIdx = newClient.id;
			int colIdx = 9 + 4 * newClient.currentRound;
			int colIdx2 = 11 + 4 * newClient.currentRound;

			model.setValueAt(
					(Object) (newClient.getRound(newClient.currentRound)
							.getEstimate() + "/" + newClient.getRound(
									newClient.currentRound)
									.getInternalEstimateAsDouble()+ "/" + 
									newClient.getRound(newClient.currentRound).random_estimate), rowIdx, colIdx);
			model.setValueAt((Object) newClient
					.getRound(newClient.currentRound).getRound_end(), rowIdx,
					colIdx2);
			GUI.totalPlayers--;
		} else if (state == RANK) {
			int colIdx = (next_round - 1 == 0) ? 6 : 6 + 4 * (next_round - 1);
			Set<Map.Entry<String, ClientLog>> s = clients.entrySet();
			Iterator<Map.Entry<String, ClientLog>> itr = s.iterator();
			while (itr.hasNext()) {
				Map.Entry<String, ClientLog> el = itr.next();
				ClientLog c = el.getValue();
				if (c.isValid()) {
					int rowIdx = c.id; // this is the id
					model.setValueAt(currentRanks.get(c.id), rowIdx, colIdx);
				}
			}
		} else if (state == INIT_ESTIMATE) {
			int colIdx = 7;
			Set<Map.Entry<String, ClientLog>> s = clients.entrySet();
			Iterator<Map.Entry<String, ClientLog>> itr = s.iterator();
			while (itr.hasNext()) {
				Map.Entry<String, ClientLog> el = itr.next();
				ClientLog c = el.getValue();
				if (c.isValid()) {
					int rowIdx = c.id; // this is the id
					model.setValueAt(
							currentEstimates.get(c.id) + c.personalOffset + "/"
									+ currentEstimates.get(c.id), rowIdx,
									colIdx);
				}
			}
		} else if (state == USERNAME) {
			int colIdx = 2;
			int rowIdx = newClient.id;
			model.setValueAt((Object) newClient.username, rowIdx, colIdx);

		} else if (state == STAGE_END) {
			int rowIdx = newClient.id;
			int colIdx = model.getColumnCount() - 2; //last but one column. don't forget the 0 indexing
			model.setValueAt(newClient.stagesEndTime.get(next_stage-1), rowIdx, colIdx);
			//update also the final rank
			colIdx = model.getColumnCount() - 1;
			model.setValueAt(newClient.getRound(gameRounds).getRank(),rowIdx,colIdx);			
			GUI.totalPlayers--;

		}
	}

	public static void computeRanks() {
		// maps distance to the truth to client_id
		MultiValueMap tmp = new MultiValueMap(); // because we may have
		// non-unique estimates
		for (int i = 0; i < clients.size(); i++) {
			double distance;
			if (currentEstimates.get(i) != -1) {
				distance = Math.abs(currentEstimates.get(i) - GUI.truth);
				tmp.put(distance, i);
			}

		}
		LinkedHashMap<Double, ArrayList<Integer>> tmp2 = SortByValue(tmp);
		List<Map.Entry<Double, ArrayList<Integer>>> list = new LinkedList<Map.Entry<Double, ArrayList<Integer>>>(
				tmp2.entrySet());
		int ctr = 1;
		for (Map.Entry<Double, ArrayList<Integer>> entry : list) {
			ArrayList<Integer> valueList = entry.getValue();
			for (int j = 0; j < valueList.size(); j++)
				currentRanks.put(valueList.get(j), ctr++);
		}
	}

	@SuppressWarnings("unchecked")
	public static LinkedHashMap<Double, ArrayList<Integer>> SortByValue(
			MultiValueMap tmp2) {
		List<Map.Entry<Double, ArrayList<Integer>>> list = new LinkedList<Map.Entry<Double, ArrayList<Integer>>>(
				tmp2.entrySet());
		Collections.sort(list,
				new Comparator<Map.Entry<Double, ArrayList<Integer>>>() {
			public int compare(
					Map.Entry<Double, ArrayList<Integer>> m1,
					Map.Entry<Double, ArrayList<Integer>> m2) {
				return (m1.getKey().compareTo(m2.getKey()));
			}
		});
		LinkedHashMap<Double, ArrayList<Integer>> result = new LinkedHashMap<Double, ArrayList<Integer>>();
		for (Map.Entry<Double, ArrayList<Integer>> entry : list) {
			result.put(entry.getKey(), entry.getValue());
		}
		return result;
	}

}
