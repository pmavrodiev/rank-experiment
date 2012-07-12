package pm;

import java.util.Vector;

public class ClientLog {

	public class gameRound {
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
	
	public int id;
	public String client_ip; //the IP of the connecting client
	public String reg_begin;
	public String reg_end;
	public Vector<gameRound> gameRounds = new Vector<gameRound>(GUI.gameRounds);
	public int currentRound; //the current round where the client is

	public ClientLog(String client_ip, String reg_begin,String reg_end,int id) {
		this.id = id;
		this.client_ip = client_ip;
		this.reg_begin = reg_begin;
		this.reg_end = reg_end;
		this.currentRound = 0;
		for (int i=0; i<GUI.gameRounds; i++)
			gameRounds.add(new gameRound());

	}
	
	public ClientLog(String client_ip) {
		this.id = -1;
		this.client_ip = client_ip;
		this.reg_begin = null;
		this.reg_end = null;
		this.currentRound = 0;
		for (int i=0; i<GUI.gameRounds; i++)
			gameRounds.add(new gameRound());
	}	
	public void initNewRound(String round_begin, int index) {
		gameRound newRound = new gameRound();
		newRound.round_begin = round_begin;		
		gameRounds.set(index, newRound);
		currentRound = index;
	}
	public void updateRound(String round_end, Double estimate, int index) {
		gameRounds.get(index).estimate = estimate.toString();
		gameRounds.get(index).round_end = round_end;
	}
	
	public gameRound getRound(int index) {
		return gameRounds.get(index);
	}
	

}
