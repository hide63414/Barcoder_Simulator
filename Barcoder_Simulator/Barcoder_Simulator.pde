import ddf.minim.*;
import ddf.minim.ugens.*;
import javax.sound.sampled.*;

//http://www.h-hosoi.skr.jp/publication/processing_primer_sample.pdf
//https://github.com/ddf/Minim
//https://github.com/soarflat-sandbox/Minim
//https://r-dimension.xsrv.jp/classes_j/minim/
//https://code.compartmental.net/minim/

PGraphics pg; 
PImage img;

Minim minim;
AudioSample stripeWave;

PVector prevMousePos;         // 前回のマウス座標を格納する変数
PVector smoothMouseVector;    // ゆるやかに変化させたマウス移動ベクトル
float smoothing = 0.05;       // マウス移動ベクトルのゆるやかさの度合い

int frame_rate = 22;          // ミラースイング周波数と同じにした 1往復45msecとして。
int scanWidth = 200;          // レーザイメージしたスキャン幅 マウス座標中心に左右均等にscanWidth/2のラインを描く
int sampleRate = frame_rate*scanWidth;  //400data×22Hz=8800Hz
int outputBufferSize = 4096;
AudioFormat format = new AudioFormat( sampleRate, // sample rate
16, // sample size in bits
1, // channels
true, // signed
true   // bigEndian
);


int movingAverageWindowSize = 2;
float lerpRatio = 0.5f;
float volume = 1.0f;
boolean barcodeWindow = true;
boolean mirrorSwing = true;
boolean stripeDraw = true;
boolean changeVolume = true;

color c0 = color (0, 0, 0);
color c1 = color (255, 255, 255);
rectStripesV rsV1;
rectStripesV rsV2;
rectStripesV rsV3;
rectStripesV rsV4;

rectStripesH rsH;
fanStripes fs;
fanStripes fs2;


void setup() {
  size(1000, 1000);
  frameRate(frame_rate);
  minim = new Minim(this); 

  img = loadImage("twinfan_800x600.png");

  prevMousePos = new PVector(mouseX, mouseY); // 初期値として現在のマウス座標を設定
  smoothMouseVector = new PVector(0, 0);

  pg = createGraphics(width, height, JAVA2D);
  //setting   
  rsV1 = new rectStripesV();
  rsV1.w = 200;
  rsV1.period = 100;
  rsV1.duty = 0.5;
  rsV1.stripeNum = 5;
  rsV1.dx = 100;
  rsV1.dy = 100;

  rsV2 = new rectStripesV();
  rsV2.w = 200;
  rsV2.period = 25;
  rsV2.duty = 0.5;
  rsV2.stripeNum = 20;
  rsV2.dx = 100;
  rsV2.dy = 300;

  rsV3 = new rectStripesV();
  rsV3.w = 200;
  rsV3.period = 10;
  rsV3.duty = 0.5;
  rsV3.stripeNum = 50;
  rsV3.dx = 100;
  rsV3.dy = 500;

  rsV4 = new rectStripesV();
  rsV4.w = 200;
  rsV4.period = 5;
  rsV4.duty = 0.5;
  rsV4.stripeNum = 100;
  rsV4.dx = 100;
  rsV4.dy = 700;

  rsH = new rectStripesH();
  rsH.w = 200;
  rsH.period = 100;
  rsH.duty = 0.5;
  rsH.stripeNum = 4;
  rsH.dx = 100;
  rsH.dy = 100;

  fs = new fanStripes();
  fs.outR = 200;
  fs.inR = 0;
  fs.period = 5;
  fs.duty = 0.5;
  fs.stripeNum = 36;
  fs.dx = 600;
  fs.dy = 100;

  fs2 = new fanStripes();
  fs2.outR = 200;
  fs2.inR = 0;
  fs2.period = 10;
  fs2.duty = 0.5;
  fs2.stripeNum = 18;
  fs2.dx = 600;
  fs2.dy = 500;
}

void keyPressed() {
  if (Character.isDigit(key)) {
    if ((key > '0') || (key <'9')) {
      lerpRatio = (key - byte('0')) * 0.1f;
      println("lerpRatio:" + lerpRatio);
    }
  }

  if (key == ' ') {
    barcodeWindow = !barcodeWindow;
  }

  if (keyCode == UP) {
    movingAverageWindowSize += 1;      
    println("moving average window size:" + movingAverageWindowSize);
  }

  if (keyCode == DOWN) {
    movingAverageWindowSize -= 1;
    if (movingAverageWindowSize < 1) movingAverageWindowSize = 1;     
    println("moving average window size:" + movingAverageWindowSize);
  }

  if ((keyCode == LEFT) || (keyCode == RIGHT)) {
    mirrorSwing = !mirrorSwing;
  }

  if (key == 'd' || key == 'D') {
    stripeDraw = !stripeDraw;
  }

  if (key == 'v' || key == 'V') {
    changeVolume = !changeVolume;
  }

  // Pのキーが入力された時に保存
  if (key == 'p' || key == 'P') {
    String path = "FanBorder"+".png";
    // 保存
    save(path);
    println("screen saved." + path);
  }
}

void drawParameter() {
  textSize(25);  //サイズを最終決定
  fill(255, 0, 0);  //色を決定
  text("ScanWidth(scroll):" + scanWidth, 50, 30);

  fill(0, 200, 50);  //色を決定  
  text("Lerp(key1-9):" + nf(lerpRatio, 1, 1), 50, 60);

  fill(50, 0, 200);  //色を決定
  text("LaserWidth(↑↓):" + movingAverageWindowSize, 50, 90);

  fill(255, 0, 0);  //色を決定
  text("Volume:" + nf(volume, 1, 2), 330, 30);
  
  fill(0, 200, 50);  //色を決定
  text("Mirroring:(←/→)" + mirrorSwing, 330, 60);
  
  fill(50, 0, 200);  //色を決定
  text("Change Draw(D);" + stripeDraw, 330, 90);

  fill(255, 0, 0);  //色を決定
  text("variable Volume:(V)" + changeVolume, 600, 30);
  
  fill(0, 200, 50);  //色を決定
  text("Window Function(space):" + barcodeWindow, 600, 60);
}

void draw() {
  background(255);

  drawParameter();

  if (stripeDraw) {
    rsV1.show();
    rsV2.show();
    rsV3.show();
    rsV4.show();
    //rsH.show();
    fs.show();
    fs2.show();
  } else {
    image(img, 100, 100);
  }
  PVector currentMousePos = new PVector(mouseX, mouseY);
  PVector mouseVector = PVector.sub(currentMousePos, prevMousePos);
  smoothMouseVector.lerp(mouseVector, smoothing);

  // マウスの移動ベクトルに対して垂直方向のベクトルを求め、正規化（長さ１に）する
  PVector lineDirection = new PVector(-smoothMouseVector.y, smoothMouseVector.x);
  lineDirection.normalize();
  // 長さscanWidth/2の長さにする
  PVector lineVector = PVector.mult(lineDirection, scanWidth/2);

  // 直線描画のため開始点と終了点座標を求める
  float startX =  mouseX - lineVector.x;
  float startY =  mouseY - lineVector.y;
  float endX =  mouseX + lineVector.x;
  float endY =  mouseY + lineVector.y;

  //範囲外だと色情報を読み込むときにIndexがはみ出るので制限する　(座標値をを描画範囲内にする）
  startX = (startX < 0) ? 0 : ((startX > width -1) ? width -1 : startX);
  startY = (startY < 0) ? 0 : ((startY > height-1) ? height-1 : startY);
  endX= (endX < 0)? 0:((endX> width-1) ? width-1:endX);
  endY= (endY < 0)? 0:((endY> height-1) ? height-1:endY);

  //データ取得用に2点の座標を定義
  PVector point1 = new PVector(startX, startY);
  PVector point2 = new PVector(endX, endY);  

  //スキャンライン上の生データプロファイルを表示
  drawProfile(point1, point2);

  //データ加工　移動平均とlerp関数と窓関数  
  float colorDatArray[] = getLineColor(point1, point2);            //2ベクトル間を結ぶ直線状の色データを配列で取得する（赤色0-255をｰ1～+1に変換も含む）
  float averageColorDataArray[] = new float[colorDatArray.length]; //移動していないときにデータがない場合があるので、ライン幅データが取得出来たら加工する
      
  if (changeVolume){
    volume = 200.0f/scanWidth;
  } else {
    volume = 1.0f;
  }
  
  if (colorDatArray.length > 1) {                                 
    averageColorDataArray = averageSmoothing(colorDatArray, movingAverageWindowSize, lerpRatio, barcodeWindow, volume );       //データ加工
  }


  float barcoderSoundArray[] = new float[averageColorDataArray.length*2];
  for (int i=0; i<averageColorDataArray.length; i++) {
    barcoderSoundArray[i] = averageColorDataArray[i];
    if (mirrorSwing) {
      barcoderSoundArray[(averageColorDataArray.length)*2-1-i] = (float)averageColorDataArray[i];
    } else {
      barcoderSoundArray[averageColorDataArray.length+i] = averageColorDataArray[i];
    }
  }

  stroke(250, 0, 150);
  strokeWeight(1); 
  for (int i=0; i<barcoderSoundArray.length; i++) {
    line(i, height-250, i, height-barcoderSoundArray[i]*100-250);
  }  


  //レーザースキャンライン描画  
  stroke(255.0f*volume*4, 0, 0);
  strokeWeight(movingAverageWindowSize);  
  line(startX, startY, endX, endY);

  minim.stop();
  minim = new Minim(this);
  format = new AudioFormat( scanWidth * frame_rate, 16, 1, true, true);
  stripeWave = minim.createSample(barcoderSoundArray, format, outputBufferSize);

  if (mousePressed == true) {
    stripeWave.trigger();
  } else {
    stripeWave.stop();
  }
  prevMousePos.set(currentMousePos);
}



void mouseWheel(MouseEvent MouseEvent) 
{
  float Wheel = MouseEvent.getCount();
  if (Wheel > 0)
  {
    scanWidth -= 25;                        //wheel moved lower
    if (scanWidth < 10) scanWidth=10;
   // volume = 200.0f/scanWidth;
  } else {                                   //wheel moved upper
    scanWidth += 25;
    //volume = 200.0f/scanWidth;
  }  
}

float[] averageSmoothing(float[] dat, int windowSize, float lerpRatio, boolean windowFunction, float vol) {
  float colorSum = 0;
  float smoothedColor = 0;
  float averageArray[] = new float[dat.length - windowSize];

  //移動平均初期値  
  for (int i=0; i<windowSize; i++) {
    colorSum += dat[i];
  }
  averageArray[0] = colorSum / windowSize;
  smoothedColor = averageArray[0];

  //移動平均計算
  for (int i=1; i<dat.length-windowSize; i++) {
    colorSum -= dat[i-1];
    colorSum += dat[i + windowSize - 1];
    smoothedColor = lerp(smoothedColor, colorSum/windowSize, lerpRatio);    
    averageArray[i] = smoothedColor;
  }

  //窓関数　ハミング関数をアレンジ
  if (windowFunction) { 
    for (int i=0; i<dat.length-windowSize; i++) {
      //averageArray[i] *= 0.54-0.46*cos(2*PI*i/(dat.length-windowSize));        //hamming window
      averageArray[i] *= 0.65-0.35*cos(2*PI*i/(dat.length-windowSize));        // barcoder window
    }
  }

  if (changeVolume) {
    for (int i=0; i<averageArray.length; i++) {
      averageArray[i] *= vol;
    }
  }

  return averageArray;
}

//ベクトル間のライン色プロファイル(生データ)をプロット
void drawProfile(PVector p1, PVector p2) {  
  ArrayList<PVector> linePixels = getLinePixels(p1, p2);
  loadPixels();
  int point = 0;
  stroke(0, 200, 50);
  strokeWeight(1);

  for (PVector pixel : linePixels) {
    int x = int(pixel.x);
    int y = int(pixel.y);
    int index = x + y * width;
    float pixelColor = red(pixels[index])/255.0f*2.0f-1.0f;
    line(point, height-50, point, height-50-pixelColor*50);
    line((linePixels.size()-1)*2-point, height-50, (linePixels.size()-1)*2-point, height-50-pixelColor*50);
    point++;
  }
}

//ベクトル間の色情報を配列で返す
float[] getLineColor(PVector p1, PVector p2) { 
  ArrayList<PVector> linePixels = getLinePixels(p1, p2);
  float lineColor[] = new float[linePixels.size()];
  float averageColor[] = new float[linePixels.size()];
  loadPixels();

  int point = 0;
  for (PVector pixel : linePixels) {
    int x = int(pixel.x);
    int y = int(pixel.y);
    int index = x + y * width;
    lineColor[point] = red(pixels[index])/255.0f*2.0f-1.0f;        //赤色データを±1に変換
    point++;
  }  
  return lineColor;
}

// 2点間の直線上のすべてのピクセルの座標を計算する関数
ArrayList<PVector> getLinePixels(PVector p1, PVector p2) {
  ArrayList<PVector> linePixels = new ArrayList<PVector>();

  float dx = p2.x - p1.x;
  float dy = p2.y - p1.y;
  float steps = max(abs(dx), abs(dy));
  float xIncrement = dx / steps;
  float yIncrement = dy / steps;

  for (float i = 0; i <= steps; i++) {
    float x = p1.x + i * xIncrement;
    float y = p1.y + i * yIncrement;
    linePixels.add(new PVector(x, y));
  }
  return linePixels;
}


class rectStripesH {
  float dx = 0;
  float dy = 0;
  float w = 100;
  float period = 20;
  float duty = 0.5;
  int stripeNum = 2;

  void show() { 
    pg.beginDraw();
    pg.noSmooth();
    pg.noStroke();
    pg.background(255, 255, 255, 0);      //背景透明  PGrahicsは透明背景が描ける

    for (int i=0; i<stripeNum; i++) {
      pg.fill(c0);
      pg.rect(0, period*i, w, period*duty);
      pg.fill(c1);
      pg.rect(0, period*(i+duty), w, period-period*duty);
    }
    pg.endDraw();
    image(pg, dx, dy);
  }
}

class rectStripesV {
  float dx = 0;
  float dy = 0;
  float w = 100;
  float period = 20;
  float duty = 0.5;
  int stripeNum = 2;

  void show() { 
    pg.beginDraw();
    pg.noSmooth();
    pg.noStroke();
    pg.background(255, 255, 255, 0);      //背景透明  PGrahicsは透明背景が描ける

    for (int i=0; i<stripeNum; i++) {
      pg.fill(c0);
      pg.rect(period*i, 0, period*duty, w);
      pg.fill(c1);
      pg.rect(period*(i+duty), 0, period-period*duty, w);
    }
    pg.endDraw();
    image(pg, dx, dy);
  }
}


class fanStripes {
  float outR = 100;
  float inR = 0;
  float dx = 0;
  float dy = 0;
  float period = 10;
  float duty = 0.5;
  int stripeNum = 2;

  void show() {
    pg.beginDraw();
    pg.noSmooth();
    pg.noStroke();
    pg.background(255, 255, 255, 0);      //背景透明  PGrahicsは透明背景が描ける
    pg.translate(0, outR);
    pg.rotate(radians(-90));
    for (int i=0; i<stripeNum; i++) {
      pg.fill(c0);
      pg.arc(0, 0, outR*2, outR*2, 0, radians(period*duty));
      pg.fill(c1);
      pg.arc(0, 0, outR*2, outR*2, radians(period*duty), radians(period));
      pg.rotate(radians(period));
    }
    pg.rotate(radians(-period * stripeNum));
    pg.arc(0, 0, inR*2, inR*2, 0, radians(period * stripeNum));
    pg.endDraw();
    image(pg, dx, dy);
  }
}


