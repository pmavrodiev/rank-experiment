package pm;

import java.util.Vector;

public class ClientLog {

	public class gameRound {
		private String round_begin;
		private String estimate;
		private String round_end;
		private double rank; //the rank in this round

		public gameRound() {
			round_begin=null;estimate=null;round_end=null; setRank(-1.0);
		}

		public void setRound_begin(String round_begin) {this.round_begin = round_begin;	}		
		public String getRound_begin() {return round_begin;	}		
		public void setEstimate(String estimate) {this.estimate = estimate;	}	
		public String getEstimate() {return estimate;}		
		public void setRound_end(String round_end) {this.round_end = round_end;	}
		public String getRound_end() {return round_end;}
		public double getRank() {return rank;}
		public void setRank(double rank) {this.rank = rank;}
		public double getOffsetEstimateAsDouble() {
			return Double.parseDouble(estimate);
		}
		public double getInternalEstimateAsDouble() {
			return Double.parseDouble(estimate) - personalOffset;
		}

	}	

	public int id;
	public String client_ip; //the IP of the connecting client
	public String reg_begin;
	public String reg_end;
	public Vector<gameRound> gameRounds = new Vector<gameRound>(GUI.gameRounds);
	public int currentRound; //the current round where the client is
	public double personalOffset; //the agent's personal offset	
	public boolean validClient; //checks to see if the client has disconnected at some point
	
	public ClientLog(String client_ip, String reg_begin,String reg_end,int id, double personal_offset) {
		this.validClient = true;
		this.personalOffset = personal_offset;
		this.id = id;
		this.client_ip = client_ip;
		this.reg_begin = reg_begin;
		this.reg_end = reg_end;
		this.currentRound = 0;
		for (int i=0; i<(GUI.gameRounds+1); i++)
			gameRounds.add(new gameRound());
	}

	public ClientLog(String client_ip) {
		this.id = -1;
		this.personalOffset = 0;
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

	public boolean getValidRound(int index) {
		if (index == this.currentRound) {
			return !(gameRounds.get(index).estimate == null);
		}
		else 
			return false;	
	}
	
	public void inValidate() {
		this.validClient = false;
	}

	public boolean isValid() {
		return this.validClient;
	}
}
