package pm;

import java.util.Vector;

public class ClientLog {

	private class gameRound {
		private String round_begin;
		private String estimate;
		private String round_end;
		@SuppressWarnings("unused")
		public gameRound() {
			round_begin=null;estimate=null;round_end=null;
		}
		@SuppressWarnings("unused")
		public void setRound_begin(String round_begin) {this.round_begin = round_begin;	}
		@SuppressWarnings("unused")
		public String getRound_begin() {return round_begin;	}
		@SuppressWarnings("unused")
		public void setEstimate(String estimate) {this.estimate = estimate;	}
		@SuppressWarnings("unused")
		public String getEstimate() {return estimate;}
		@SuppressWarnings("unused")
		public void setRound_end(String round_end) {this.round_end = round_end;	}
		@SuppressWarnings("unused")
		public String getRound_end() {return round_end;}
	}	

	public String client_ip; //the IP of the connecting client
	public String reg_begin;
	public String reg_end;
	public Vector<gameRound> gameRounds;
	private int currentRound; //the current round where the client is

	public ClientLog(String client_ip, String reg_begin) {
		this.client_ip = client_ip;
		this.reg_begin = reg_begin;
		this.reg_end = null;
		this.currentRound = 0;
		gameRounds = new Vector<gameRound>(GUI.gameRounds);
	}

}
