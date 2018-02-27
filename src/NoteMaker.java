import java.awt.Toolkit;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.ClipboardOwner;
import java.awt.datatransfer.StringSelection;
import java.awt.datatransfer.Transferable;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Scanner;

public final class NoteMaker implements ClipboardOwner {

	public static void main(String[] args) {
		NoteMaker nm = new NoteMaker();
		Scanner scanner = new Scanner(System.in);
		String line = "";
		String out = "";
		int noteCount = 0;
		
		boolean left = true;
		while(!line.equals("exit")) {
			System.out.println("Enter the note: ");
			line = scanner.nextLine();
			String note= line.toUpperCase().trim();
			
			System.out.println("Enter the duration: ");
			line = scanner.nextLine();
			String delay = line.trim().replace('/', '_').toLowerCase();
			double del = Double.parseDouble(delay);
			
			if(note.isEmpty() || note.equalsIgnoreCase("\n")) {
				if(left) {
					out += "db "+Math.round(del*16)+", \t"+Math.round(del*8)+"\n";
				}
				else {
					out += "."+Math.round(del*16)+"\ndb ."+Math.round(del*8)+", \t";
				}
			}
			else {
				if(left) {
					out += "db "+note+"1, \t"+note+"2\ndb "+note+"3, \t"+note+"4\ndb ."+Math.round(del*16)+", \t";
				}
				else {
					out += note+"1\ndb "+note+"2, \t"+note+"3\ndb "+note+"4, \t."+Math.round(del*16)+"\n";
				}
			}
			left = !left;
			System.out.println("Exit? ");
			line = scanner.nextLine();
		}
		nm.setClipboardContents(out);
		SimpleDateFormat sdf = new SimpleDateFormat("HH-mm-ss");
		try {
			PrintWriter txt = new PrintWriter(sdf.format(new Date())+".txt");
			txt.write(out);
			txt.close();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
		scanner.close();
		
	}
	public static String sweepGenerator() {
		String notes = "C0,Db0,D0,Eb0,E0,F0,Gb0,G0,Ab0,A0,Bb0,B0,C1,Db1,D1,Eb1,E1,F1,Gb1,G1,Ab1,A1,Bb1,B1,C2,Db2,D2,Eb2,E2,F2,Gb2,G2,Ab2,A2,Bb2,B2,C3,Db3,D3,Eb3,E3,F3,Gb3,G3,Ab3,A3,Bb3,B3,C4,Db4,D4,Eb4,E4,F4,Gb4,G4,Ab4,A4,Bb4,B4,C5,Db5,D5,Eb5,E5,F5,Gb5,G5,Ab5,A5,Bb5,B5,C6,Db6,D6,Eb6,E6,F6,Gb6,G6,Ab6,A6,Bb6,B6,C7,Db7,D7,Eb7,E7,F7,Gb7,G7,Ab7,A7,Bb7,B7,C8,Db8,D8,Eb8,E8,F8,Gb8,G8,Ab8,A8,Bb8,B8";
		String[] notesList = notes.split(",");
		boolean left = true;
		String out = "";
		for(int i=0;i<notesList.length;i++) {
			if(left) {
				out += "db "+notesList[i]+"1, \t"+notesList[i]+"2\ndb "+notesList[i]+"3, \t"+notesList[i]+"4\ndb .1, \t";
			}
			else {
				out += "\t"+notesList[i]+"1\ndb "+notesList[i]+"2, \t"+notesList[i]+"3\ndb "+notesList[i]+"4, \t.1\n";
			}
			left = !left;
		}
		return out;
	}
	@Override
	public void lostOwnership(Clipboard clipboard, Transferable contents) {
	}
	
	public void setClipboardContents(String aString){
	    StringSelection stringSelection = new StringSelection(aString);
	    Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
	    clipboard.setContents(stringSelection, this);
	  }

}
