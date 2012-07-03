package pm;



import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.util.Vector;


import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.SwingUtilities;
import javax.swing.UIManager;
import javax.swing.table.DefaultTableModel;






public class GUI extends JFrame {

	private static final long serialVersionUID = 1L;
	/*game related stuff*/
	public static final int gameRounds = 10;
	public static final int REGISTRATION=0;	
	public static final int ROUND_BEGIN=1;
	public static final int ROUND_ESTIMATE=2;
	public static final int ROUND_END=3;
	
	public static Vector<ClientLog> clients;;
	/*swing stuff*/
	private static JPanel jPanel0;
	private static JButton startstop;
	private static JScrollPane scrollpane;
	private static JTable logtable;
	

	private static final String PREFERRED_LOOK_AND_FEEL = "javax.swing.plaf.metal.MetalLookAndFeel";
	private MyServer myServer;

	public GUI(final MyServer myServer) {
		this.myServer = myServer;
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
		
		clients = new Vector<ClientLog>();
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
		System.out.println(getJPanel0().getBounds());
		//the scroll pane
		c.weightx = 1; c.weighty=1;
		c.gridx = 0; c.gridy = 1;c.anchor = GridBagConstraints.NORTHWEST;
		
		this.add(getScrollPane(),c);
		System.out.println(scrollpane.getBounds());

	}

	private JButton getStartStopButton() {
		if (startstop == null) {
			startstop = new JButton("Start");
			startstop.addActionListener(new ServerStartStopActionListener(myServer));
		}
		return startstop;
	}

	private JPanel getJPanel0() {
		if (jPanel0 == null) {
			jPanel0 = new JPanel();
			jPanel0.setLayout(new GridBagLayout());
			GridBagConstraints c = new GridBagConstraints();
			c.gridx = 0; c.gridy = 0;jPanel0.add(getStartStopButton(),c); 	
		}
		return jPanel0;
	}

	private JScrollPane getScrollPane() {
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
				String c = "Round_" + i + "_BEGIN"; String c2 = "Estimate"; String c3 = "Round_" + i + "_END";
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
			if (lnfClassname == null)
				lnfClassname = UIManager.getCrossPlatformLookAndFeelClassName();
			UIManager.setLookAndFeel(lnfClassname);
		} catch (Exception e) {
			System.err.println("Cannot install " + PREFERRED_LOOK_AND_FEEL
					+ " on this platform:" + e.getMessage());
		}
	}

	/**
	 * Main entry of the class.
	 * Note: This class is only created so that you can easily preview the result at runtime.
	 * It is not expected to be managed by the designer.
	 * You can modify it as you like.
	 * @throws Exception 
	 */
	public static void main(String[] args) throws Exception {
		installLnF();
		final MyServer myServer = new MyServer();	
		SwingUtilities.invokeLater(new Runnable() {
			@Override
			public void run() {
				GUI frame = new GUI(myServer);
				frame.setDefaultCloseOperation(GUI.EXIT_ON_CLOSE);
				frame.setTitle("Server Control Monitor");
				frame.getContentPane().setPreferredSize(frame.getSize());
				frame.pack();
				frame.setLocationRelativeTo(null);
				frame.setVisible(true);
			}
		});
	}

	public static void updateGUITable(ClientLog newClient,int state) {
		if (state == REGISTRATION) {
			DefaultTableModel model = (DefaultTableModel) getLogTable().getModel();
			model.addRow(new Object[] {newClient.client_ip,newClient.reg_begin});
		}
		else if (state == ROUND_BEGIN) {
	
		}
		else if (state == ROUND_ESTIMATE || state == ROUND_END) {
		
		}
		
	}

}
