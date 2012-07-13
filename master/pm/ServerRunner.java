package pm;
import java.awt.BorderLayout;
import java.awt.EventQueue;

import javax.swing.JButton;
import javax.swing.JFrame;

import org.eclipse.jetty.server.Handler;
import org.eclipse.jetty.server.handler.ContextHandlerCollection;

import pm.MyServer;
import pm.ServerStartStopActionListener;


public class ServerRunner extends JFrame{

	private static final long serialVersionUID = 1L;
	private JButton btnStartStop;

	public ServerRunner(final MyServer myServer) {
		super("Start/Stop Server");
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		btnStartStop = new JButton("Start");
		btnStartStop.addActionListener(new ServerStartStopActionListener(myServer));
		add(btnStartStop,BorderLayout.CENTER);
		setSize(300,300);
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
		setVisible(true);
	}
	/*
	public static void main(String[] args) throws Exception {		
		final MyServer myServer = new MyServer();		
		Runnable runner = new Runnable() {
			@Override
			public void run() {
				new ServerRunner(myServer);
			}
		};
		EventQueue.invokeLater(runner);
	}
	*/
	
	
}
