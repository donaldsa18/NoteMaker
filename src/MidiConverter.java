import java.io.File;
import java.io.FileNotFoundException;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Scanner;

import javax.sound.midi.InvalidMidiDataException;
import javax.sound.midi.MidiEvent;
import javax.sound.midi.MidiMessage;
import javax.sound.midi.MidiSystem;
import javax.sound.midi.MidiUnavailableException;
import javax.sound.midi.Sequence;
import javax.sound.midi.Sequencer;
import javax.sound.midi.ShortMessage;
import javax.sound.midi.Track;
public class MidiConverter {
	public static final int NOTE_ON = 0x90;
	public static final int NOTE_OFF = 0x80;
	public static final String[] NOTE_NAMES = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"};

	public static void main(String[] args) throws Exception {
		Scanner scanner = new Scanner(System.in);
		File[] files = (new File("convert")).listFiles(new FilenameFilter() { 
			public boolean accept(File dir, String filename)
			{ return filename.endsWith(".mid"); }
		} );
		for(int i=0;i<files.length;i++) {
			
			System.out.println("Converting "+files[i].getName());
			
			Sequence sequence = MidiSystem.getSequence(files[i]);
			System.out.println("Number of tracks: "+sequence.getTracks().length);
			double ticktime = 15*sequence.getMicrosecondLength()/(125.0*sequence.getTickLength());
			System.out.println("Ticktime: "+ticktime);
			String out = "";
			
			if(sequence.getResolution() == Sequence.PPQ) {
				String line = scanner.nextLine();
				double bpm = (Double.parseDouble(line.substring(line.indexOf(':')+1).toUpperCase()));
				ticktime = (60000.0/(bpm)*192);
			}
			else {
				ticktime = (125.0/sequence.getResolution())/80;
			}
			for(int l=0;l<sequence.getTracks().length;l++) {
				boolean hasNote = false;
				Track track = sequence.getTracks()[l];
				long lastNote = 0;
				
				boolean left = true;
				out += "\n;Track"+l+"\n";
				note:
				for(int j=0;j<track.size()-1;j++) {
					MidiEvent e1 = track.get(j);
					MidiMessage m1 = e1.getMessage();
					if(m1 instanceof ShortMessage) {
						ShortMessage sm = (ShortMessage) m1;
						int key = sm.getData1();
						int command = sm.getCommand();
						int octave = ((key/12)-1);
						if(octave >= 0 && octave <=8 && command != NOTE_OFF && sm.getData2() != 0) {
							String noteName = NOTE_NAMES[key%12]+((key/12)-1);
							for(int k=j+1;k<track.size();k++) {
								MidiEvent e2 = track.get(k);
								MidiMessage m2 = e2.getMessage();
								if(m2 instanceof ShortMessage) {
									ShortMessage sm2 = (ShortMessage) m2;
									int command2 = sm2.getCommand();
									int key2 = sm2.getData1();
									if (key == key2 && (command2 == NOTE_OFF || sm2.getData2() == 0)) {
										int duration = (int)Math.ceil((int)(e2.getTick()-e1.getTick())*ticktime);
										duration = Math.min(10, duration);
										if(e1.getTick()-lastNote > 0) {
											if(left) {
												out += "db ."+duration+", \t."+duration+"\n";
											}
											else {
												out += "."+duration+"\ndb ."+duration+", \t";
											}
										}
										lastNote = e2.getTick();
										
										if(left) {
											out += "db "+noteName+"1, \t"+noteName+"2\ndb "+noteName+"3, \t"+noteName+"4\ndb ."+duration+", \t";
										}
										else {
											out += noteName+"1\ndb "+noteName+"2, \t"+noteName+"3\ndb "+noteName+"4, \t."+duration+"\n";
										}
										hasNote = true;
										left = !left;
										continue note;
									} 
								}
							}
						}
					}
				}
				if(hasNote) {
					for(int j=0;j<5;j++) {
						if(left) {
							out += "db 0x00, \t0x00\n";
						}
						else {
							out += "0x00\ndb 0x00, \t";
						}
					}
				}
			}
			try {
				String newName = "converted/"+files[i].getName().substring(0, files[i].getName().indexOf('.'))+".asm";
				PrintWriter txt = new PrintWriter(newName);
				txt.write(out);
				txt.close();
				NotePlayer.playSong(newName);
				System.out.println("Playing "+files[i].getName());
				play(files[i]);
			} catch (FileNotFoundException e) {
				e.printStackTrace();
			}
		}
		scanner.close();
	}
	
	public static void play(File file) throws InvalidMidiDataException, IOException, MidiUnavailableException, InterruptedException {
		Sequence sequence = MidiSystem.getSequence(file);
		Sequencer sequencer = MidiSystem.getSequencer();
		sequencer.open();
		sequencer.setSequence(sequence);
		sequencer.start();
		Thread.sleep(sequencer.getMicrosecondLength());
	}
}

