import java.io.IOException;
import java.net.DatagramPacket;
import java.net.InetAddress;
import java.net.MulticastSocket;
import java.nio.ByteBuffer;
import java.util.Scanner;
import java.io.File;

public class sender extends Thread {

	protected MulticastSocket socket = null;
	protected byte[] buf = new byte[256];
	protected InetAddress group = null;
	protected static int thePort = 42055;
	protected static String theIP = "237.7.7.7";
	protected payload thePayload = new payload();
	protected static String filename = "Data.csv";
	protected Scanner scanner;
	public static double timeScale = 1;

	public void init_sender() throws IOException {
		socket = new MulticastSocket(thePort);
		socket.setReuseAddress(true);
		group = InetAddress.getByName(theIP);
		socket.joinGroup(group);
		scanner = new Scanner(new File(filename));
		scanner.useDelimiter(",");
		if (scanner.hasNext()) { String hdr_row = scanner.nextLine(); }// Skipp header row
		else System.out.println("Cout not open file " + filename + " for reading");
	}

	public sender() throws IOException {
		this.init_sender();
	}

	public sender(int newSocket) throws IOException {
		thePort = newSocket;
		this.init_sender();
	}

	public sender(String newIP) throws IOException {
		theIP = newIP;
		this.init_sender();
	}

	public sender(String newIP, int newSocket) throws IOException {
		thePort = newSocket;
		theIP = newIP;
		this.init_sender();
	}

	protected double timeStamp = 0;
	protected double DeltaTime;
	protected boolean keepGoing = true;
	protected double last_ts = 0;
	protected int pauseTime = 0;
	protected boolean first_loop = true;

	public static void usageMessage() {
		System.out.println("USAGE: arguments are:");
		System.out.println("-h print usage information");
		System.out.println("-? print usage infomation");
		System.out.println("-m Multicast IP    (default=" + theIP + ")");
		System.out.println("-p port            (default=" + thePort + ")");
		System.out.println("-f filename        (default=" + filename + ")");
		System.out.println("-s speed factor  (default=" + timeScale + ")");
		System.out.println("\n\n\n To run reciever:\n    java -cp test.jar receiver");
		System.exit(0);
	}

	public static void main(String[] args) {
		System.setProperty("java.net.preferIPv4Stack", "true");
		int c;
		final GetOpt getopt = new GetOpt(args, "m:p:f:s:h?");
		while ((c = getopt.getopt()) != getopt.optEOF) {
			if (((char) c == '?') || ((char) c == 'h'))
				usageMessage();
			else if ((char) c == 'm')
				theIP = getopt.optArgGet();
			else if ((char) c == 'p')
				thePort = Integer.valueOf(getopt.processArg(getopt.optArgGet(), thePort));
			else if ((char) c == 'f')
				filename = getopt.optArgGet();
			else if ((char) c == 's')
				timeScale = 1.0 / Double.valueOf(getopt.processArg(getopt.optArgGet(), timeScale));
			else
				usageMessage(); // undefined option
		}

		System.out.println("Server Starting up!"); // Display the string.
		System.out.println("Starting Sender on port: " + thePort + " for MC: " + theIP + " Using datafile:" + filename
				+ " at rate " + 1.0 / timeScale + " X");
		try {
			sender A = new sender();
			A.run();
		} catch (IOException e) {
			e.printStackTrace();
		}

	}

	public void readRow() {
		if (scanner.hasNext()) {
			Scanner vScanner = new Scanner(scanner.nextLine());
			vScanner.useDelimiter(",");
			timeStamp = vScanner.nextDouble();
			if (first_loop) {
				first_loop = false;
				last_ts = timeStamp;
			}
			for (int i = 0; i < 3; i++) {
				thePayload.pos1[i] = vScanner.nextDouble();
			}
			for (int i = 0; i < 3; i++) {
				thePayload.pos2[i] = vScanner.nextDouble();
			}
			for (int i = 0; i < 3; i++) {
				thePayload.pos3[i] = vScanner.nextDouble();
			}
			for (int i = 0; i < 4; i++) {
				thePayload.quat1[i] = vScanner.nextDouble();
			}
			for (int i = 0; i < 4; i++) {
				thePayload.quat2[i] = vScanner.nextDouble();
			}
			for (int i = 0; i < 4; i++) {
				thePayload.quat3[i] = vScanner.nextDouble();
			}

			thePayload.engine_flag = vScanner.nextInt();
			thePayload.reserved = vScanner.nextInt();
			// thePayload.reserved =Integer.valueOf(scanner.nextLine().substring(1));
			// System.out.println("\n\n\n"+rc+"\n\n");
		} else {
			keepGoing = false;
		}

		DeltaTime = timeStamp - last_ts;
		last_ts = timeStamp;
		if (DeltaTime >= 0) {
			pauseTime = (int) (1000 * timeScale * DeltaTime);
		} else {
			pauseTime = 1000;
		}
		byte[] newBuf = thePayload.packBuffer();
		int cpySize = Math.min(buf.length, newBuf.length);
		System.arraycopy(newBuf, 0, buf, 0, cpySize);

		// for(int i=0; i<newBuf.length; i++) { System.out.print(newBuf[i]+"; "); if
		// ((i%8)==7) System.out.println(""); }
		// payload.print_payload();
		// if (timeStamp > 1.5/40.0) {keepGoing = false; }
	}

	public void run() {
		try {
			int count = 0;
			while (true) {
				readRow();
				if (!keepGoing)
					break;
				count++;
				System.out.println("send loop#" + count + " TS=" + timeStamp + "  PT=" + pauseTime);
				multicast(thePayload.theRawBuffer);
				Thread.sleep(pauseTime);
			}
			socket.leaveGroup(group);
			socket.close();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}

	}

	public void multicast(String multicastMessage) throws IOException {
		buf = multicastMessage.getBytes();
		multicast(buf);
	}

	public void multicast(byte[] rawBuf) throws IOException {
		java.net.DatagramSocket asocket = new java.net.DatagramSocket();
		group = InetAddress.getByName(theIP);

		DatagramPacket packet = new DatagramPacket(rawBuf, rawBuf.length, group, thePort);
		asocket.send(packet);
		asocket.close();
	}
}
