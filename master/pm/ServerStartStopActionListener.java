package pm;


import java.awt.Cursor;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.table.DefaultTableModel;

import pm.MyServer;

public class ServerStartStopActionListener implements ActionListener{
	private final MyServer myServer;

	public ServerStartStopActionListener(MyServer myServer) {
		this.myServer = myServer;
	}

	@Override
	public void actionPerformed(ActionEvent actionEvent) {
		JButton btnStartStop =  (JButton) actionEvent.getSource();
		if(myServer.isStarted()){
			btnStartStop.setText("Stopping...");
			btnStartStop.setCursor(new Cursor(Cursor.WAIT_CURSOR));
			try {
				myServer.stop();
				DefaultTableModel model = (DefaultTableModel) GUI.getLogTable().getModel();
				model.getDataVector().removeAllElements();
				model.fireTableDataChanged();
				GUI.clients.clear();
				
			} catch (Exception exception) {
				exception.printStackTrace();
			}
			btnStartStop.setText("Start");
			btnStartStop.setCursor(new Cursor(Cursor.DEFAULT_CURSOR));
		}
		else if(myServer.isStopped()){
			btnStartStop.setText("Starting...");
			btnStartStop.setCursor(new Cursor(Cursor.WAIT_CURSOR));
			try {
				myServer.start();
			} catch (Exception exception) {
				exception.printStackTrace();
			}
			btnStartStop.setText("Stop");
			btnStartStop.setCursor(new Cursor(Cursor.DEFAULT_CURSOR));
		}
	}
}