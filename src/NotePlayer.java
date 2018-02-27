import java.io.File;
import java.io.FileNotFoundException;
import java.util.HashMap;
import java.util.Random;
import java.util.Scanner;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.LineUnavailableException;
import javax.sound.sampled.SourceDataLine;

public class NotePlayer {
	private static SourceDataLine sdl;
	private static int bpm;
	private static float sampleRate;
	private static Random rand = new Random();
    public static void main(String[] args) throws LineUnavailableException, FileNotFoundException, InterruptedException {
        double[] off = {0};
        sampleRate = 44100;
        AudioFormat af = new AudioFormat(sampleRate, 8, 1, true, false );
        sdl = AudioSystem.getSourceDataLine( af );
        sdl.open();
        sdl.start();
        bpm = 200;
        
        HashMap<String,Double> noteDict = new HashMap<>();
        Scanner s = new Scanner(notesList);
        while (s.hasNextLine()) {
			String line = s.nextLine();
			double f = (Double.parseDouble(line.substring(line.indexOf(':')+1).toUpperCase()));
			String n = line.substring(0,line.indexOf(':')).trim().toUpperCase();
			noteDict.put(n, f);
        }
        s.close();
        s = new Scanner(new File("song.asm"));
        double[] notes = new double[4];
        int count = 0;
        String nextNote = "";
        String lastNote = "";
        while(s.hasNextLine()) {
        	String clean = s.nextLine().replaceAll("db", "").replaceAll(" ", "").replaceAll("\t", "").trim();
        	if(clean.startsWith(";")) {
        		continue;
        	}
        	if(clean.contains(";")) {
        		clean = clean.substring(0, clean.indexOf(';'));
        	}
        	String[] line = clean.split(",");
        	float delay = 0;
        	for(String note : line) {
        		if(noteDict.containsKey(note.substring(0, note.length()-1))) {
        			nextNote = note.substring(0, note.length()-1);
        		}
        		else if(note.contains(".") && noteDict.containsKey(nextNote)) {
        			delay = Float.parseFloat(note.replace(".", ""));
        			System.out.println("Playing "+nextNote+" for "+note.replace(".", ""));
        			addBeep(new double[]{noteDict.get(nextNote)},delay/2);
        			Thread.sleep((long) ((1000.0*60/bpm)/16));
        			nextNote = null;
        		}
        		else if(note.charAt(0) == 'P') {
        			if(note.contains("_")) {
            			delay = Float.parseFloat(note.substring(1, 2))/Float.parseFloat(note.substring(3));
            		}
        			else {
        				delay = Float.parseFloat(note.substring(1));
        			}
        			if(lastNote.equals(note)) {
        				Thread.sleep((long) (1000.0*delay/16));
        			}
        			else if(noteDict.containsKey(nextNote)) {
        				System.out.println("Playing "+nextNote+" for "+note);
        				addBeep(new double[]{noteDict.get(nextNote)},delay);
        				Thread.sleep((long) ((1000.0*60/bpm)/16));
        				nextNote = null;
        			}
        		}
        		else if(note.equals("0x00")) {
        			s.close();
        			return;
        		}
        		lastNote = note;
        	}
        }
        s.close();
        sdl.drain();
        sdl.stop();
    }
    
    public static void playSong(String asm) throws LineUnavailableException, FileNotFoundException, InterruptedException {
    	double[] off = {0};
        sampleRate = 44100;
        AudioFormat af = new AudioFormat(sampleRate, 8, 1, true, false );
        sdl = AudioSystem.getSourceDataLine( af );
        sdl.open();
        sdl.start();
        bpm = 200;
        
        HashMap<String,Double> noteDict = new HashMap<>();
        Scanner s = new Scanner(notesList);
        while (s.hasNextLine()) {
			String line = s.nextLine();
			double f = (Double.parseDouble(line.substring(line.indexOf(':')+1).toUpperCase()));
			String n = line.substring(0,line.indexOf(':')).trim().toUpperCase();
			noteDict.put(n, f);
        }
        s.close();
        s = new Scanner(new File(asm));
        double[] notes = new double[4];
        int count = 0;
        String nextNote = "";
        String lastNote = "";
        while(s.hasNextLine()) {
        	String clean = s.nextLine().replaceAll("db", "").replaceAll(" ", "").replaceAll("\t", "").trim();
        	if(clean.startsWith(";") || clean.isEmpty() || clean.startsWith("\n")) {
        		continue;
        	}
        	if(clean.contains(";")) {
        		clean = clean.substring(0, clean.indexOf(';'));
        	}
        	String[] line = clean.split(",");
        	float delay = 0;
        	for(String note : line) {
        		if(noteDict.containsKey(note.substring(0, note.length()-1))) {
        			nextNote = note.substring(0, note.length()-1);
        		}
        		else if(note.contains(".") && noteDict.containsKey(nextNote)) {
        			delay = Float.parseFloat(note.replace(".", ""));
        			System.out.println("Playing "+nextNote+" for "+note);
        			addBeep(new double[]{noteDict.get(nextNote)},delay/2);
        			nextNote = null;
        		}
        		else if(note.charAt(0) == 'P') {
        			if(note.contains("_")) {
            			delay = Float.parseFloat(note.substring(1, 2))/Float.parseFloat(note.substring(3));
            		}
        			else {
        				delay = Float.parseFloat(note.substring(1));
        			}
        			if(lastNote.equals(note)) {
        				Thread.sleep((long) (1000.0*delay/8));
        			}
        			else if(noteDict.containsKey(nextNote)) {
        				System.out.println("Playing "+nextNote+" for "+note);
        				addBeep(new double[]{noteDict.get(nextNote)},delay);
        				nextNote = null;
        			}
        		}
        		else if(note.equals("0x00")) {
        			s.close();
        			return;
        		}
        		lastNote = note;
        	}
        }
        s.close();
        sdl.drain();
        sdl.stop();
    }
    public static void addBeep(double[] freq,double delay) {
    	byte[] maxbuf = new byte[]{(byte)10};
    	byte[] minbuf = new byte[]{(byte)-10};
    	byte[] buf = new byte[1];
    	
    	for(int i = 0;i<delay*60*sampleRate/bpm;i++) {
    		boolean wave = false;
    		float temp = 0;
	    	for(int j = 0;j<freq.length;j++)
	    	{
	    		double sin = Math.sin((i*Math.PI*2/sampleRate)*freq[j])> 0 ? 1 : -1;
	    		temp += sin;
	    	}
	    	if(temp > 0) {
	    		wave = true;
	    	}
	    	sdl.write(wave ? maxbuf : minbuf, 0, 1);
    	}
    }
    private static String notesList = "C0:16.35\nC#0:17.32\nD0:18.35\nD#0:19.45\nE0:20.6\nF0:21.83\nF#0:23.12\nG0:24.5\nG#0:25.96\nA0:27.5\nA#0:29.14\nB0:30.87\nC1:32.7\nC#1:34.65\nD1:36.71\nD#1:38.89\nE1:41.2\nF1:43.65\nF#1:46.25\nG1:49\nG#1:51.91\nA1:55\nA#1:58.27\nB1:61.74\nC2:65.41\nC#2:69.3\nD2:73.42\nD#2:77.78\nE2:82.41\nF2:87.31\nF#2:92.5\nG2:98\nG#2:103.83\nA2:110\nA#2:116.54\nB2:123.47\nC3:130.81\nC#3:138.59\nD3:146.83\nD#3:155.56\nE3:164.81\nF3:174.61\nF#3:185\nG3:196\nG#3:207.65\nA3:220\nA#3:233.08\nB3:246.94\nC4:261.63\nC#4:277.18\nD4:293.66\nD#4:311.13\nE4:329.63\nF4:349.23\nF#4:369.99\nG4:392\nG#4:415.3\nA4:440\nA#4:466.16\nB4:493.88\nC5:523.25\nC#5:554.37\nD5:587.33\nD#5:622.25\nE5:659.25\nF5:698.46\nF#5:739.99\nG5:783.99\nG#5:830.61\nA5:880\nA#5:932.33\nB5:987.77\nC6:1046.5\nC#6:1108.73\nD6:1174.66\nD#6:1244.51\nE6:1318.51\nF6:1396.91\nF#6:1479.98\nG6:1567.98\nG#6:1661.22\nA6:1760\nA#6:1864.66\nB6:1975.53\nC7:2093\nC#7:2217.46\nD7:2349.32\nD#7:2489.02\nE7:2637.02\nF7:2793.83\nF#7:2959.96\nG7:3135.96\nG#7:3322.44\nA7:3520\nA#7:3729.31\nB7:3951.07\nC8:4186.01\nC#8:4434.92\nD8:4698.63\nD#8:4978.03\nE8:5274.04\nF8:5587.65\nF#8:5919.91\nG8:6271.93\nG#8:6644.88\nA8:7040\nA#8:7458.62\nB8:7902.13\nC0:16.35\nDb0:17.32\nD0:18.35\nEb0:19.45\nE0:20.6\nF0:21.83\nGb0:23.12\nG0:24.5\nAb0:25.96\nA0:27.5\nBb0:29.14\nB0:30.87\nC1:32.7\nDb1:34.65\nD1:36.71\nEb1:38.89\nE1:41.2\nF1:43.65\nGb1:46.25\nG1:49\nAb1:51.91\nA1:55\nBb1:58.27\nB1:61.74\nC2:65.41\nDb2:69.3\nD2:73.42\nEb2:77.78\nE2:82.41\nF2:87.31\nGb2:92.5\nG2:98\nAb2:103.83\nA2:110\nBb2:116.54\nB2:123.47\nC3:130.81\nDb3:138.59\nD3:146.83\nEb3:155.56\nE3:164.81\nF3:174.61\nGb3:185\nG3:196\nAb3:207.65\nA3:220\nBb3:233.08\nB3:246.94\nC4:261.63\nDb4:277.18\nD4:293.66\nEb4:311.13\nE4:329.63\nF4:349.23\nGb4:369.99\nG4:392\nAb4:415.3\nA4:440\nBb4:466.16\nB4:493.88\nC5:523.25\nDb5:554.37\nD5:587.33\nEb5:622.25\nE5:659.25\nF5:698.46\nGb5:739.99\nG5:783.99\nAb5:830.61\nA5:880\nBb5:932.33\nB5:987.77\nC6:1046.5\nDb6:1108.73\nD6:1174.66\nEb6:1244.51\nE6:1318.51\nF6:1396.91\nGb6:1479.98\nG6:1567.98\nAb6:1661.22\nA6:1760\nBb6:1864.66\nB6:1975.53\nC7:2093\nDb7:2217.46\nD7:2349.32\nEb7:2489.02\nE7:2637.02\nF7:2793.83\nGb7:2959.96\nG7:3135.96\nAb7:3322.44\nA7:3520\nBb7:3729.31\nB7:3951.07\nC8:4186.01\nDb8:4434.92\nD8:4698.63\nEb8:4978.03\nE8:5274.04\nF8:5587.65\nGb8:5919.91\nG8:6271.93\nAb8:6644.88\nA8:7040\nBb8:7458.62\nB8:7902.13\n";
}
