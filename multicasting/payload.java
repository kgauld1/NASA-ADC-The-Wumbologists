import java.io.IOException;
import java.net.DatagramPacket;
import java.net.InetAddress;
import java.net.MulticastSocket;
import java.nio.ByteBuffer;

class payload {
   static public double  pos1[] = new double[3];
   static public double  pos3[] = new double[3];
   static public double  pos2[] = new double[3];
   static public double quat1[] = new double[4];
   static public double quat2[] = new double[4];
   static public double quat3[] = new double[4];
   static public int engine_flag;
   static public int reserved;
   public static byte[] theRawBuffer = new byte[22*8]; // 22 parameters, 8 bytes each

   public static void print_payload()
    {
       System.out.println("Pos1 ="+pos1[0]+","+pos1[1]+","+pos1[2]);
       System.out.println("Pos2 ="+pos2[0]+","+pos2[1]+","+pos2[2]);
       System.out.println("Pos3 ="+pos3[0]+","+pos3[1]+","+pos3[2]);
       System.out.println("Quat1="+quat1[0]+","+quat1[1]+","+quat1[2]+","+quat1[3]);
       System.out.println("Quat2="+quat2[0]+","+quat2[1]+","+quat2[2]+","+quat2[3]);
       System.out.println("Quat3="+quat3[0]+","+quat3[1]+","+quat3[2]+","+quat3[3]);
       System.out.println("Eng_Flag="+engine_flag+", reservered="+reserved);
    }

// Sets all fields to 0
   public payload() {      
       for (int i=0; i<3; i++) {  pos1[i]=0;  pos2[i]=0;  pos3[i]=0;}
       for (int i=0; i<4; i++) { quat1[i]=0; quat2[i]=0; quat3[i]=0;}
       engine_flag=0; reserved=0;
    }

// sets theRawBuffer[] to have same value as the specified newBuffer
   public static void setBuffer(byte[] newBuffer) 
   {       
     int cpySize=Math.min(theRawBuffer.length, newBuffer.length);
     System.arraycopy(newBuffer, 0, theRawBuffer, 0, cpySize);
     unpackBuffer();
   }

// reverses the order of bytes in a byte[] (first becomes last, and vice versa)
   public static byte[] reversebuffer (byte [] input)
   {
       byte[] rv = new byte[input.length];
       //System.out.println(input.length);
       for (int i=0, j=input.length-1; j>=0; i++, j--)
        { rv[i]=input[j];  /*System.out.println("in["+i+"]="+rv[i]);}*/ }
       return rv;
   }

// Casts 8 bytes of theRawBuffer (starting at offset) as a double (in LittleEndian form), and returns it //
   public static double extractDouble(int offset) {
     byte[] bytes = new byte[8];  // One doubles worth of data
     System.arraycopy(theRawBuffer, offset, bytes, 0, 8);
     bytes=reversebuffer(bytes);
     return (ByteBuffer.wrap(bytes).getDouble());
   }

// Casts 4 bytes of theRawBuffer (starting at offset) as an int (in LittleEndian form), and returns it //
   public static int extractInt(int offset) {
     byte[] bytes = new byte[4];  // One Ints worth of data
     System.arraycopy(theRawBuffer, offset, bytes, 0, 4);
     bytes=reversebuffer(bytes);
     return (ByteBuffer.wrap(bytes).getInt());
   }

// Sets all the parameters to the values that they have in theRawBuffer buffer
   public static void unpackBuffer() {
     int offset=0;
     for (int i=0; i<3; i++, offset+=8) {  pos1[i]=extractDouble(offset); }
     for (int i=0; i<3; i++, offset+=8) {  pos2[i]=extractDouble(offset); }
     for (int i=0; i<3; i++, offset+=8) {  pos3[i]=extractDouble(offset); }
     for (int i=0; i<4; i++, offset+=8) { quat1[i]=extractDouble(offset); }
     for (int i=0; i<4; i++, offset+=8) { quat2[i]=extractDouble(offset); }
     for (int i=0; i<4; i++, offset+=8) { quat3[i]=extractDouble(offset); }
     engine_flag=extractInt(offset); offset+=4;
     reserved=extractInt(offset); offset+=4;
   }

// Place specified value into "offset" location in theRawBuffer. (as 8-bytes in LittleEndian form) //
   public static void packDouble(int offset, double val) {
     byte[] bytes = new byte[8];  // One doubles worth of data
     ByteBuffer.wrap(bytes).putDouble(val);
     bytes=reversebuffer(bytes);  // swap to little Endian (JAVA is BE)
     System.arraycopy(bytes, 0, theRawBuffer, offset, 8);
   }

// Place specified value into "offset" location in theRawBuffer. (as 8-bytes in LittleEndian form) //
   public static void packInt(int offset, int val) {
     byte[] bytes = new byte[4];  // One doubles worth of data
     ByteBuffer.wrap(bytes).putInt(val);
     bytes=reversebuffer(bytes);  // swap to little Endian (JAVA is BE)
     System.arraycopy(bytes, 0, theRawBuffer, offset, 4);
   }

// Sets the theRawBufffer to have values associated with all the current values of the parameters
   public byte[] packBuffer() {
     int offset=0;
     for (int i=0; i<3; i++, offset+=8) {  packDouble(offset,  pos1[i]); }
     for (int i=0; i<3; i++, offset+=8) {  packDouble(offset,  pos2[i]); }
     for (int i=0; i<3; i++, offset+=8) {  packDouble(offset,  pos3[i]); }
     for (int i=0; i<4; i++, offset+=8) {  packDouble(offset, quat1[i]); }
     for (int i=0; i<4; i++, offset+=8) {  packDouble(offset, quat2[i]); }
     for (int i=0; i<4; i++, offset+=8) {  packDouble(offset, quat3[i]); }
     packInt(offset, engine_flag); offset+=4;
     packInt(offset, reserved); offset+=4;
     return theRawBuffer;
   }
}
