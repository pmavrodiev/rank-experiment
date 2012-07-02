package pm;
import java.awt.BorderLayout;
import java.awt.EventQueue;

import javax.swing.JButton;
import javax.swing.JFrame;

import org.eclipse.jetty.server.Handler;
import org.eclipse.jetty.server.handler.ContextHandlerCollection;

import pm.JettyServer;
import pm.ServerStartStopActionListener;


public class ServerRunner extends JFrame{
	private static final long serialVersionUID = 8261022096695034L;

	private JButton btnStartStop;

	public ServerRunner(final JettyServer jettyServer) {
		super("Start/Stop Server");
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		btnStartStop = new JButton("Start");
		btnStartStop.addActionListener
		(new ServerStartStopActionListener(jettyServer));
		add(btnStartStop,BorderLayout.CENTER);
		setSize(300,300);
		Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
			@Override
			public void run() {
				if(jettyServer.isStarted()) {
					try {
						jettyServer.stop();
					} catch (Exception exception) {
						exception.printStackTrace();
					}
				}
			}
		},"Stop Jetty Hook")); 
		setVisible(true);
	}
	
	public static void main(String[] args) {
		ContextHandlerCollection contexts = new ContextHandlerCollection();
		
		contexts.setHandlers(new Handler[] 
			{ new AppContextBuilder().buildWebAppContext()});
		
		final JettyServer jettyServer = new JettyServer();
		jettyServer.setHandler(contexts);
		Runnable runner = new Runnable() {
			@Override
			public void run() {
				new ServerRunner(jettyServer);
			}
		};
		EventQueue.invokeLater(runner);
	}
	
	
	
}
