PImage src1;
PImage src2;
PImage dst1;
PImage dst2;

void setup() {
float [] grad_ds_src1= new float[5000];
float [] grad_ds_src2= new float[5000];
float [] grad_ds_dst1= new float[5000];
float [] grad_ds_dst2= new float[5000];
float Res=0 , Res1 = 0;

size(1324, 730);

src1= loadImage("ss4.jpg");
src1.loadPixels();
dst1 = createImage(src1.width, src1.height,RGB);
dst1.loadPixels();
float threshold = 127;
 for (int x = 0; x < src1.width; x++) {
   for (int y = 0; y < src1.height; y++ ) {
     int loc = x + y*src1.width;
      // Test the brightness against the threshold
     if (brightness(src1.pixels[loc]) > threshold) {
       dst1.pixels[loc]  = color(255);  // White
      } else {
       dst1.pixels[loc]  = color(0);    // Black
      }
    }
  }
 // changed the pixels in destination
dst1.updatePixels();
grad_ds_src1 = gradiant(src1);
grad_ds_dst1 = gradiant(dst1);

src2= loadImage("ss3.jpg");
src2.loadPixels();
dst2 = createImage(src2.width, src2.height,RGB);
dst2.loadPixels();
for (int x = 0; x < src2.width; x++) {
    for (int y = 0; y < src2.height; y++ ) {
      int loc = x + y*src2.width;
      // Test the brightness against the threshold
      if (brightness(src2.pixels[loc]) > threshold) {
        dst2.pixels[loc]  = color(255);  // White
      }  else {
        dst2.pixels[loc]  = color(0);    // Black
      }
    }
  }
 // changed the pixels in destination
dst2.updatePixels();
grad_ds_src2 = gradiant(src2);
grad_ds_dst2 = gradiant(dst2);
Res= Cos(grad_ds_src1,grad_ds_src2); //<>//
//Res1= Cos(grad_ds_dst1, grad_ds_dst2);
println(" Comparision Result = " , Res );
//println("Comparision result (threshold) = ", Res1);
} 
 


float [] gradiant (PImage img)
{
float[][] sobelx =  {{ -1,  0, 1 }, 
                    { -2, 0, 2 }, 
                    { -1,  0, 1 }};
                    
float[][] sobely =  {{ -1,  -2, -1 }, 
                    { 0, 0, 0 }, 
                    { 1,  2, 1 }};

float [][] gradx= new float[img.height][img.width]; // gradient feature vector for x axis
float [][] grady= new float[img.height][img.width]; // gradient feature vector for y axis
float [][] grad= new float[img.height][img.width]; //  gradient feature vector
float [][] angle= new float[img.height][img.width]; //gradient feature vector angle
float [] grad_4= new float[img.height*img.width*4]; // features extracted  
float [] grad_4_ds= new float[3000]; // store Features after downsampling 

for (int y = 1; y < img.height-1; y++) 
  for (int x = 1; x < img.width-1; x++) {
    float gx = 0, gy = 0 ; 
    for (int ky = -1; ky <= 1; ky++) 
      for (int kx = -1; kx <= 1; kx++) {
        int index = (y + ky) * img.width + (x + kx);
        float b = brightness(img.pixels[index]);
        gx += sobelx[ky+1][kx+1] * b;
        gy += sobely[ky+1][kx+1] * b;
      }
      gradx [y][x] = gx;
      grady [y][x] = gy;
      grad [y][x] = sqrt( sq(gx) + sq(gy));  //Intensity
  }


//calculate the angles 
for (int h = 1; h < img.height-1; h++) 
  for (int w = 1; w < img.width-1; w++) 
{  
  angle[h][w] = atan2(grady[h][w], gradx[h][w]);
  
}

// Decomposition of Gradient Vector using Method 
int pos= 0; //  initial point of the tuple 
for (int k = 1; k < img.height-1; k++) 
{ 
  for (int l = 1; l < img.width-1; l++) 
{ 
  if (angle [k][l] >=0 && angle [k][l] <=PI/2) //Gradient feature vector in 1 quadarant
  {
    pos = (k-1)*img.width*4+ (l-1)*4;
    grad_4[pos+1] = grad [k][l]* cos (degrees(angle [k][l]));
    grad_4[pos+2] = grad [k][l]* sin (degrees(angle [k][l]));
    grad_4[pos+3] = 0;
    grad_4[pos+4] = 0;
    
  }
   else if (angle [k][l] > PI/2 && angle [k][l] <=PI) //Gradient feature vector in 2 quadarant
   {
    pos = (k-1)*img.width*4+ (l-1)*4;
    grad_4[pos+1] = 0;
    grad_4[pos+2] = grad [k][l]* sin (degrees(angle [k][l]));
    grad_4[pos+3] = -1 * grad [k][l]* cos (degrees(angle [k][l]));
    grad_4[pos+4] = 0; 
     
   }
    else if (angle [k][l] > PI && angle [k][l] <= 3*PI/2) //Gradient feature vector in 3 quadarant
    {
    pos = (k-1)*img.width*4+ (l-1)*4;
    grad_4[pos+1] = 0;
    grad_4[pos+2] = 0;
    grad_4[pos+3] = (-1)*grad [k][l]* cos (degrees(angle [k][l]));
    grad_4[pos+4] = (-1)*grad [k][l]* sin (degrees(angle [k][l]));
  
    }
    else                                            //Gradient feature vector in 4 quadarant
    {
  pos = (k-1)*img.width*4+ (l-1)*4;
    grad_4[pos+1] = grad [k][l]* cos (degrees(angle [k][l]));
    grad_4[pos+2] = 0;
    grad_4[pos+3] = 0;
    grad_4[pos+4] = (-1)*grad [k][l]* sin (degrees(angle [k][l]));
  
    }
}
}


// Downsampling = image into 9*9 

int d1 = img.height/9, d2 = img.width/9*4;
int posi=0;
int  w1 = 1;
 float g1 = 0, g2 = 0, g3=0, g4 =0 ; 
      // for storing the sum of tuples for a block of 9*9
      for (int h=1 ; h<= d1*9; h= h+img.height/9) // loop for starting point of block traversing the pixels of  whole image of height*width*4
       {  
       for (int w=1 ; w<= d2*9; w = w+d2){
            for (int ky = h; ky <= h+d1; ky++)  // loop for calculating sum of tuples for a pixel for a block
            for (int kx = w; kx <= w+d2/4; kx++) {
                posi = (ky-1)*d2 +(kx-1)*4;
                g1 += grad_4[posi+1];  
                g2 += grad_4[posi+2];
                g3 += grad_4[posi+3];
                g4 += grad_4[posi+4];
            }
           grad_4_ds [w1] = g1;
            w1++; 
             grad_4_ds [w1] = g2;
            w1++;
             grad_4_ds [w1] = g3;
            w1++;
            grad_4_ds [w1] = g4;
            w1++;
       }       
 }
return (grad_4_ds);
}

float Cos(float [] grada, float [] gradb)
{
  float res1 =0.0, res2=0.0, res3 =0.0, res =0.0;
   for (int i = 1; i<325; i++)
  {
    res1 +=   grada[i]*gradb[i];
    res2 +=  sq(grada[i]);
    res3 +=  sq(gradb[i]);
  }
  res = res1/( sqrt(res2)*sqrt(res3));
  
  return res;
}
