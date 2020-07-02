import java.util.*;
import java.net.*;
import java.io.*;
import java.nio.*;

// {alt, lat, long, q0, q1, q2, q3}
float[] CREW = new float[7];
float[] LAS = new float[7];
float[] BOOSTER = new float[7];
int mcTime = 0;
int mcEngine = 0;


class payload {
  double  pos1[] = new double[3];
  double  pos3[] = new double[3];
  double  pos2[] = new double[3];
  double quat1[] = new double[4];
  double quat2[] = new double[4];
  double quat3[] = new double[4];
  int engine_flag;
  int reserved;
  byte[] theRawBuffer = new byte[22*8]; // 22 parameters, 8 bytes each

  public void assign_vals() {
    for (int i = 0; i < 3; i++) {
      CREW[i] = (float)pos1[i];
      LAS[i] = (float)pos2[i];
      BOOSTER[i] = (float)pos3[i];
    }
    for (int i =3; i<7; i++) {
      CREW[i] = (float)quat1[i-3];
      LAS[i] = (float)quat2[i-3];
      BOOSTER[i] = (float)quat3[i-3];
    }

    mcEngine = engine_flag;
  }
  public void print_payload()
  {
    System.out.println("Pos1 ="+pos1[0]+","+pos1[1]+","+pos1[2]);
    System.out.println("Pos2 ="+pos2[0]+","+pos2[1]+","+pos2[2]);
    System.out.println("Pos3 ="+pos3[0]+","+pos3[1]+","+pos3[2]);
    System.out.println("Quat1="+quat1[0]+","+quat1[1]+","+quat1[2]+","+quat1[3]);
    System.out.println("Quat2="+quat2[0]+","+quat2[1]+","+quat2[2]+","+quat2[3]);
    System.out.println("Quat3="+quat3[0]+","+quat3[1]+","+quat3[2]+","+quat3[3]);
    System.out.println("Eng_Flag="+engine_flag+", reservered="+reserved);
    System.out.println("----------------------------------");
  }

  // Sets all fields to 0
  public payload() {      
    for (int i=0; i<3; i++) {  
      pos1[i]=0;  
      pos2[i]=0;  
      pos3[i]=0;
    }
    for (int i=0; i<4; i++) { 
      quat1[i]=0; 
      quat2[i]=0; 
      quat3[i]=0;
    }
    engine_flag=0; 
    reserved=0;
  }

  // sets theRawBuffer[] to have same value as the specified newBuffer
  public void setBuffer(byte[] newBuffer) 
  {       
    int cpySize=Math.min(theRawBuffer.length, newBuffer.length);
    System.arraycopy(newBuffer, 0, theRawBuffer, 0, cpySize);
    unpackBuffer();
  }

  // reverses the order of bytes in a byte[] (first becomes last, and vice versa)
  public byte[] reversebuffer (byte [] input)
  {
    byte[] rv = new byte[input.length];
    //System.out.println(input.length);
    for (int i=0, j=input.length-1; j>=0; i++, j--)
    { 
      rv[i]=input[j];  /*System.out.println("in["+i+"]="+rv[i]);}*/
    }
    return rv;
  }

  // Casts 8 bytes of theRawBuffer (starting at offset) as a double (in LittleEndian form), and returns it //
  public double extractDouble(int offset) {
    byte[] bytes = new byte[8];  // One doubles worth of data
    System.arraycopy(theRawBuffer, offset, bytes, 0, 8);
    bytes=reversebuffer(bytes);
    return (ByteBuffer.wrap(bytes).getDouble());
  }

  // Casts 4 bytes of theRawBuffer (starting at offset) as an int (in LittleEndian form), and returns it //
  public int extractInt(int offset) {
    byte[] bytes = new byte[4];  // One Ints worth of data
    System.arraycopy(theRawBuffer, offset, bytes, 0, 4);
    bytes=reversebuffer(bytes);
    return (ByteBuffer.wrap(bytes).getInt());
  }

  // Sets all the parameters to the values that they have in theRawBuffer buffer
  public void unpackBuffer() {
    int offset=0;
    for (int i=0; i<3; i++, offset+=8) {  
      pos1[i]=extractDouble(offset);
    }
    for (int i=0; i<3; i++, offset+=8) {  
      pos2[i]=extractDouble(offset);
    }
    for (int i=0; i<3; i++, offset+=8) {  
      pos3[i]=extractDouble(offset);
    }
    for (int i=0; i<4; i++, offset+=8) { 
      quat1[i]=extractDouble(offset);
    }
    for (int i=0; i<4; i++, offset+=8) { 
      quat2[i]=extractDouble(offset);
    }
    for (int i=0; i<4; i++, offset+=8) { 
      quat3[i]=extractDouble(offset);
    }
    engine_flag=extractInt(offset); 
    offset+=4;
    reserved=extractInt(offset); 
    offset+=4;
  }

  // Place specified value into "offset" location in theRawBuffer. (as 8-bytes in LittleEndian form) //
  public void packDouble(int offset, double val) {
    byte[] bytes = new byte[8];  // One doubles worth of data
    ByteBuffer.wrap(bytes).putDouble(val);
    bytes=reversebuffer(bytes);  // swap to little Endian (JAVA is BE)
    System.arraycopy(bytes, 0, theRawBuffer, offset, 8);
  }

  // Place specified value into "offset" location in theRawBuffer. (as 8-bytes in LittleEndian form) //
  public void packInt(int offset, int val) {
    byte[] bytes = new byte[4];  // One doubles worth of data
    ByteBuffer.wrap(bytes).putInt(val);
    bytes=reversebuffer(bytes);  // swap to little Endian (JAVA is BE)
    System.arraycopy(bytes, 0, theRawBuffer, offset, 4);
  }

  // Sets the theRawBufffer to have values associated with all the current values of the parameters
  public byte[] packBuffer() {
    int offset=0;
    for (int i=0; i<3; i++, offset+=8) {  
      packDouble(offset, pos1[i]);
    }
    for (int i=0; i<3; i++, offset+=8) {  
      packDouble(offset, pos2[i]);
    }
    for (int i=0; i<3; i++, offset+=8) {  
      packDouble(offset, pos3[i]);
    }
    for (int i=0; i<4; i++, offset+=8) {  
      packDouble(offset, quat1[i]);
    }
    for (int i=0; i<4; i++, offset+=8) {  
      packDouble(offset, quat2[i]);
    }
    for (int i=0; i<4; i++, offset+=8) {  
      packDouble(offset, quat3[i]);
    }
    packInt(offset, engine_flag); 
    offset+=4;
    packInt(offset, reserved); 
    offset+=4;
    return theRawBuffer;
  }
}





PShape las, crew, booster, ground;
PImage groundTexture;
float lasheight = 23.0886, boosterheight = 2.159;
String[] file;
int frames = 0, centerx = 0, centery = 0, centerz = 600;
int[] camera = {0, 0, 0};
int llaRad = 10, textS = 18;
//                x/y len   z   pic x  pic y
int[] gdCoords = {61000, 0, 2972, 2742};
ArrayList<Float> time = new ArrayList<Float>();
ArrayList<Integer> engines = new ArrayList<Integer>();

void settings() {
  size((int)1800 * displayWidth/3000, (int)1800 * displayHeight/2000, P3D);
  textS = 36;
  System.setProperty("java.net.preferIPv4Stack", "true");
}

void setup() {
  las = loadShape("las.obj");
  crew = loadShape("crew.obj");
  booster = loadShape("booster.obj");
  groundTexture = loadImage("groundTexture earth.jpg");
  gdCoords[2] = groundTexture.width;
  gdCoords[3] = groundTexture.height;
  frameRate(200);
  lights();
  float fov = PI/3.0;
  float cameraZ = (height/2.0) / tan(fov/2.0);
  perspective(fov, float(width)/float(height), 0.1, cameraZ*10000.0);
}

void rotate(float z, float y, float x) {
  rotateY(z);
  rotateX(y);
  rotateZ(x);
}

float[] llaToXyz(float lon, float lat, float alt, int r) {
  r += alt;
  float[] xyz = {r * (cos(lon) - sin(lat)), r  * (sin(lon) - sin(lat)), r * sin(lat)};
  return xyz;
}

float[] QuatToYRP(float q0, float q1, float q2, float q3) {
  float yrp[] = new float[3];
  // roll
  yrp[0] = atan2(2*(q0*q1 + q2*q3), 1 - 2*(q1*q1 + q2*q2));
  // pitch
  yrp[1] = asin(2*(q0*q2 - q3*q1));
  // yaw
  yrp[2] = atan2(2*(q0*q3 + q1*q2), 1 - 2*(q2*q2 + q3*q3));
  return yrp;
}

float[] cCs = {0, 0, 0};
String abort = "";
boolean t = true;
long tm = 0;
float[] firstBoost = new float[3];
void readValues() {
  payload thePayload = new payload();
  byte[] buf = new byte[22*8];
  try {
    int count=1;
    MulticastSocket socket = new MulticastSocket(42055);
    InetAddress group = InetAddress.getByName("237.7.7.7");
    socket.joinGroup(group);
    DatagramPacket packet = new DatagramPacket(buf, buf.length);
    if (packet.getLength() != 0) {
      socket.receive(packet);
      byte[] theNewMsg = packet.getData();
      thePayload.setBuffer(packet.getData());
      thePayload.assign_vals();
      if (t) {
        t = false;
        tm = millis();
        for(int i = 0; i < 3; i++)
          firstBoost[i] = BOOSTER[i];
      }
      String strI  = "client Loop# " + count + "  byte="+packet.getLength();
      count++;
      System.out.println(strI);
      socket.leaveGroup(group);
      socket.close();
    }
  } 
  catch (IOException e) {
    e.printStackTrace();
  }
}
int pEng = 0;
void draw() {
  readValues();
  background(200);
  lights();
  booster.setFill(color(40, 80, 55));
  pushMatrix();
  translate(width/2, height/2);
  camera(cCs[0], cCs[1] - 1000, cCs[2] + 200, // idk what these do
    0, 0, 0, // center
    0, 1, 0); // idk what these do



  pushMatrix();
  float[] yrp = QuatToYRP(LAS[3], LAS[4], LAS[5], LAS[6]);
  float[] xyz = llaToXyz(LAS[2], LAS[1], LAS[0], llaRad);

  translate(xyz[0], xyz[1], xyz[2]);
  rotate(yrp[0], yrp[1], yrp[2]);

  shape(las, 0, 0);

  popMatrix();

  pushMatrix();
  yrp = QuatToYRP(CREW[3], CREW[4], CREW[5], CREW[6]);

  xyz = llaToXyz(CREW[2], CREW[1], CREW[0], llaRad);
  cCs[0] = xyz[0]; 
  cCs[1] = xyz[1]; 
  cCs[2] = xyz[2];

  translate(xyz[0], xyz[1] + 5, xyz[2]);
  rotate(yrp[0], yrp[1], yrp[2]);

  shape(crew, 0, 0);
  popMatrix();

  pushMatrix();
  yrp = QuatToYRP(BOOSTER[3], BOOSTER[4], BOOSTER[5], BOOSTER[6]);

  xyz = llaToXyz(BOOSTER[2], BOOSTER[1], BOOSTER[0], llaRad);
  translate(xyz[0], xyz[1] +15, xyz[2]);
  rotate(yrp[0], yrp[1], yrp[2]);

  shape(booster, 0, 0);
  popMatrix();


  pushMatrix();
  xyz = llaToXyz(firstBoost[2], firstBoost[1], firstBoost[0], llaRad);
  translate(xyz[0], xyz[1] + 700, xyz[2]);
  rotateX(PI/2);
  rotateZ(PI/5);
  fill(255);
  beginShape();
  texture(groundTexture);
  vertex(-gdCoords[0], -gdCoords[0], gdCoords[1], 0, 0);
  vertex( gdCoords[0], -gdCoords[0], gdCoords[1], gdCoords[2], 0);
  vertex( gdCoords[0], gdCoords[0], gdCoords[1], gdCoords[2], gdCoords[3]);
  vertex(-gdCoords[0], gdCoords[0], gdCoords[1], 0, gdCoords[3]);
  endShape();
  popMatrix();


  popMatrix();

  fill(255, 255, 0);
  textSize(15);
  text("Time: " + (millis()-tm)/1000.0, 20, 40);
  text("LAS\nAlt: " + LAS[0] + "\nLat:" + LAS[1] + "\nLong:" + LAS[2], 20, 120);
  text("Crew\nAlt: " + CREW[0] + "\nLat:" + CREW[1] + "\nLong:" + CREW[2], 20, 240);
  text("Booster\nAlt: " + BOOSTER[0] + "\nLat:" + BOOSTER[1] + "\nLong:" + BOOSTER[2], 20, 360);
  String bEng = "OFF";
  if (mcEngine % 2 == 1) bEng = "ON";
  String lEng = "OFF";
  if (mcEngine > 1) lEng = "ON";
  if (pEng > 1 && mcEngine < 1) abort = "\nABORT ACTIVATED";
  pEng = mcEngine;
  text("BOOSTER ENGINE: "+ bEng + "\nLAS ENGINE: " + lEng + abort, 20, 480);
}