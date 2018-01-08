//Thursday, 12 March 2016
//Final Project Farahiyah Syarafina (11/319311/TK/38440)


//setting for users and channel
int N = 35;                         //number of users
int CH = 4;                         //number of channel available

//setting for simulation
int MAX_ITERATION = 500;             //max iteration

//setting for power
float POWER = 0.1;                    //POWER 100mW
double noise_power = 1e-13;            //noise power
float NOISE_POWER = (float)noise_power;

//setting for topopogy
float TX [] = new float [N];        //transmitter (x coordinate)
float TY [] = new float [N];        //transmitter (y coordinate)
float RX [] = new float [N];        //receiver (x coordinate)
float RY [] = new float [N];        //receiver (y coordinate)
float AX [] = new float [N];        //indicator (x coordinate)
float AY [] = new float [N];        //indicator (y coordinate)
float D [] = new float [N];         //random distance between TX and RX
float THETA [] = new float [N];     //random THETA 
float DX [] = new float [N];        
float DY [] = new float [N];
int DIAMETER_TX = 35;                       //diameter of circle x
int DIAMETER_RX = 15;                       //diameter of circle y
int MAX_OVERLAP = 45;
int MAX_DISTANCE = 60;                      //maximum distance between transmitter and receiver
float D_EUCLID [][] = new float [N][N];     //matrix of euclidean distance between transmitter and receiver
int ch [] = new int [N];

//potential game calculation
float GAIN [][] = new float [N][N];         //matrix of gain
float GAIN_POWER [][] = new float [N][N];   //matrix of gain power

float INTERFERENCE [][] = new float [N][CH]; //interference of player in a channel
float GAIN_INTERFERENCE [] = new float [N];  //interference total of player

float utility [][] = new float [N][CH];      //utility total
float utility_temp;

//performance measurement
float SINR [] = new float [N];                //SIR linear
float SINR_db [] = new float [N];             //SIR dB
float initial_sinr [] = new float [N];

float THROUGHPUT [] = new float [N];         //throughput
float THROUGHPUT_TEMP [] = new float [N]; 

float potential_function [] = new float [N]; 
float potential_function_final [] = new float [N];

float network_throughput_final [] = new float [N];    //network throughput

int time = 0;

float check_distance;

int MIN_DISTANCE_TX = 60;

int player; 
int BEST_CHANNEL;
float MAX_UTILITY;

PrintWriter output;

//==========================================================================================================//
//INITIALIZATION//
//==========================================================================================================//

void setup () {
  size (650, 650);
  fill (255, 255);
  smooth();
  rect (0, 0, width, height);
  frameRate(0.5);

  

  //==========================================================================================================//
  // find coordinat for TX and RX
  //==========================================================================================================//
  
  //random circle no overlap
  for (int a=0; a<N; a++) {
    TX[a] = random (MAX_OVERLAP, width-MAX_OVERLAP);          //coordinate of transmitter (x)
    TY[a] = random (MAX_OVERLAP, height-MAX_OVERLAP);         //coordinate of transmitter (y)
    
    if (a == 0) {
      continue;
    }

    int fail = 1;
    while (fail == 1) {
      TX[a] = random (MAX_OVERLAP, width-MAX_OVERLAP);          //coordinate of transmitter (x)
      TY[a] = random (MAX_OVERLAP, height-MAX_OVERLAP);         //coordinate of transmitter (y)

      for (int b=a-1; b>=0; b--) {
        if (a == b) {
          continue;
        }

        float check_distance;
        check_distance = dist(TX[a], TY[a], TX[b], TY[b]);
        if (check_distance < MIN_DISTANCE_TX) {
          fail = 1;
          break; 
        }

        else fail = 0;

        if (fail == 0) {
          continue;
        }
      }

      if (fail == 0) {
        break;
      }
    }

    if (fail == 0) {
      continue;
    }
  }

  for (int n=0; n<N; n++) {
    D[n] = random (DIAMETER_TX, MAX_DISTANCE);                //distance between TX and RX
    THETA[n] = random (0.0, 360.0);
    DX[n] = D[n]*cos(THETA[n]);
    DY[n] = D[n]*sin(THETA[n]);
    RX[n] = TX[n] + DX[n];                    //coordinate of receiver (x)
    RY[n] = TY[n] + DY[n];                    //coordinate of receiver (y)
    
    println ("koordinat TX");
    println (int(TX[n]), int(TY[n]), DIAMETER_TX, DIAMETER_TX);
    println ("koordinat RX");
    println (int(RX[n]), int(RY[n]), DIAMETER_RX, DIAMETER_RX);

    ch[n] = int (random(0, CH));               //CHANNEL assignment
    println ("channel initialization list");
    println (ch[n]);

    for (;;) {
      AX [n] = random (MAX_OVERLAP, width-MAX_OVERLAP);
      AY [n] = random (MAX_OVERLAP, height-MAX_OVERLAP);

      if ((TX[n]-AX[n])*(TX[n]-AX[n])+(TY[n]-AY[n])*(TY[n]-AY[n]) < 45) {
        break;
      }
    } 
  }


  //==========================================================================================================//
  // euclidean distance and GAIN calculation
  //==========================================================================================================//
  for (int i=0; i<N; i++) { 
    for (int j=0; j<N; j++) {
      D_EUCLID [i][j] = sqrt((sq(TX[i]-RX[j])+sq(TY[i]-RY[j])));
      GAIN [i][j] = sq(1/(2*PI*D_EUCLID[i][j]));
      GAIN_POWER [i][j] = (POWER * GAIN[i][j]);
      println ("i: " + i + "j: " +j + " " + (POWER * GAIN[i][j]));
      println (D_EUCLID [i][j]);
    }
  }

  //initial SINR and throughput calculation  
  for (int z=0; z<N; z++) {    
    float gi_init = 0.0;
    float gi_init_temp;
    for (int d=0; d<N; d++) {
      if (z == d) {
        continue;
      }
      if (ch[z] == ch[d]) {
        gi_init_temp = GAIN_POWER[d][z];
        gi_init = gi_init + gi_init_temp;
      }
    }
    initial_sinr[z] = ((GAIN_POWER[z][z])/(gi_init+NOISE_POWER));
    //float f = (float)c;  // Converts the value of 'c' from a double to a float
    //float f = (float)initial_sinr[z];
    //THROUGHPUT[z] = (1/CH)*(log(1+initial_sinr[z])/log(2));
  }

  output = createWriter ("POTENTIAL GAME OUTPUT.txt");
}

void draw () {

  output.println ("FINAL PROJECT");
  output.println ("Farahiyah Syarafina (11/319311/TK/38440)");
  output.println (" ");
  output.println (" ");

  //output channel initialization
  output.println ("player" + "\t" + "channel initialization list");
  for (int out_chan=0; out_chan<N; out_chan++) 
  {
    output.println (out_chan + "\t" + ch[out_chan]);
  }

  //output SINR initialization list
  output.println (" ");
  output.println ("player" + "\t" + "SINR initialization list");
  for (int out_sinr=0; out_sinr<N; out_sinr++) 
  {
    output.println(out_sinr + "\t" +initial_sinr[out_sinr]);
  }
  
  //output throughput initialization list
  //output.println (" ");
  //output.println ("player" + "\t" + "throughput initialization list");
   //for (int out_thr=0; out_thr<N; out_thr++) 
  //{
    //output.println (out_thr + "\t" + THROUGHPUT[out_thr]);
  //}
  //output.println ("network throughput initialization: " +);

  //output utility initialization list
  output.println (" ");
  output.println ("player" + "\t" + "utility initialization");
  for (int out_ut=0; out_ut<N; out_ut++) {
    output.println (out_ut + "\t" + utility[out_ut][ch[out_ut]]);
  }
  //output.println ("total utility initialization: " +);

  //label of the table
  output.println (" ");
  output.println ("iter" + "\t" + "player" + "\t" + "best channel" + "\t"  + "utility" + "\t" + "\t" + "SINR" + "\t" + "\t"+ "throughput" + "\t" +  "network throughput" + "\t" + "potential function");

  int iteration = 1;
  while (iteration < MAX_ITERATION) {
    //iterasi ke:
    //giliran player ke:
    for (player = 0; player<N; player++) {
      println (" ");
      println ("=================================");
      print ("Iteration: " +iteration);
      println (" Player: " +player);
      println ("Initial channel: " +ch[player]);
      
      //player ke: cek channel ke:
      for (int channel=0; channel<CH; channel++) {
        //println ("UTILITY KANAL KE : " +channel);
        //cek masing2 user apakah ada di kanal sama atau tidak
        
        utility[player][channel] = 0.0;
        for (int a=0; a<N; a++) {           
          //indeks TX dan RX sama abaikan, lajut iterasi
          if (a==player) {
            continue;
          }
          if (channel == ch[a]) {
            INTERFERENCE[player][ch[a]] = -GAIN_POWER[a][player]-GAIN_POWER[player][a];
            utility_temp = INTERFERENCE[player][ch[a]];
            utility[player][channel] = utility[player][channel]+utility_temp;
          }
        }      
      }

      //find best channel
      MAX_UTILITY = utility[player][0];
      BEST_CHANNEL = 0;
      for (int c=0; c<CH; c++) {
        if (utility [player][c] > MAX_UTILITY) {
          MAX_UTILITY = utility[player][c] ;
          BEST_CHANNEL = c;
        }
      }

      //get best channel
      ch[player] = BEST_CHANNEL;

      //gain interference after new channel
      float gi_temp;
      GAIN_INTERFERENCE [player]= 0.0;
      for (int k=0; k<N; k++) {
        if (player == k) {
          continue;
        }
        
        if (BEST_CHANNEL == ch[k]) {
          gi_temp = GAIN_POWER[k][player];
          GAIN_INTERFERENCE [player] = GAIN_INTERFERENCE [player] + gi_temp;
        }
      }
      
      //calculate utility for every player after best channel //utility [player]
      for (int p=0; p<N; p++) {
        utility[p][ch[p]] = 0.0;
        for (int u=0; u<N; u++) {
          if (p == u) {
            continue;
          }
          
          if (ch[p] == ch[u]) {
            INTERFERENCE[p][ch[p]] = -GAIN_POWER[u][p]-GAIN_POWER[p][u];
            utility_temp = INTERFERENCE[p][ch[p]];
            utility[p][ch[p]] = utility[p][ch[p]]+utility_temp;
          } 
        }
      }

      for (int coba=0; coba<N; coba++) {
        println (utility[coba][ch[coba]]);
      }

      //potential function calculation
      float potential_function_temp;
      float potential_function = 0.0;
      for (int pf=0; pf<N; pf++) {
        potential_function_temp = utility[pf][ch[pf]];
        potential_function = potential_function + potential_function_temp;
      }
      potential_function_final [player] = ((potential_function)/2);


      //throughput and SINR calculation
      for (int z=0; z<N; z++) {    
        float gi_init = 0.0;
        float gi_init_temp;
        for (int d=0; d<N; d++) {
          if (z == d) {
            continue;
          }

          if (ch[z] == ch[d]) {
            gi_init_temp = GAIN_POWER[d][z];
            gi_init = gi_init + gi_init_temp;
          }
        }
        SINR[z] = ((GAIN_POWER[z][z])/(gi_init+NOISE_POWER));
        //float f = (float)SINR[z];
        THROUGHPUT[z] = (log(1+SINR[z])/log(2));
      }
      
      for (int cb=0; cb<N; cb++) {
        println ("SINR");
        println (SINR[cb]);
        println (" ");
        println ("throughput");
        println (THROUGHPUT[cb]);
        println (" ");
      }

      //calculate SINR for every player in its channel
      SINR[player] = ((GAIN_POWER[player][player])/(GAIN_INTERFERENCE [player]+NOISE_POWER));
      //float f = (float)(SINR[player]);
      THROUGHPUT[player] = (log(1+SINR[player])/log(2));      
      
      //network throughput calculation
      float network_throughput_temp;
      float network_throughput = 0.0;
      for (int b=0; b<N; b++) {
        network_throughput_temp = THROUGHPUT[b];
        network_throughput = network_throughput + network_throughput_temp;
      }
      network_throughput_final [player] = (network_throughput)/CH;

      println (" ");
      println ("Utility total: " +MAX_UTILITY);
      println ("Best channel: " +BEST_CHANNEL);
      print ("SIR player: ");
      println (SINR[player]);
      println ("Throughput player: " +THROUGHPUT[player]);
      println (" ");
      print ("Network throughput: ");
      println (network_throughput_final[player]);
      println (" ");
      print ("Potential function: ");
      println (potential_function_final [player]);
      //print ("SIR dB: ");        
      //println (SIR_db[player]);
      //println (" ");
      
      println ("======================");
      println (" ");
      

      fill(255, 255);
      rect(0, 0, width, height);
      for (int n=0; n<N; n++) {
        if (ch[n] == 0) {
          fill(#FF0000, 150);
        } 
        else if (ch[n] == 1) {
          fill(#4f9909, 150);
        } 
        else if (ch[n] == 2) {
          fill(#4f99ff, 150);
        } 
        else if (ch[n] == 3) {
          fill(#ff9900, 150);
        } 
        else if (ch[n] == 4) {
          fill(#003366, 150);
        } 
        else if (ch[n] == 5) {
          fill(#ffff00, 150);
        } 
        else if (ch[n] == 6) {
          fill(#ff66ff, 150);
        } 
        else if (ch[n] == 7) {
          fill(#330099, 150);
        }

        ellipseMode (CENTER);
        ellipse (int(TX[n]), int(TY[n]), 2, 2);
        ellipse (int(AX[n]), int(AY[n]), 2, 2);
        line (int(TX[n]), int(TY[n]), int(AX[n]), int(AY[n]));         //line indicator
        line (int(TX[n]), int(TY[n]), int(RX[n]), int(RY[n]));         //line between TX and RX

        ellipse (int(TX[n]), int(TY[n]), DIAMETER_TX, DIAMETER_TX);                  //circle of TRANSMITTER
        ellipse (int(RX[n]), int(RY[n]), DIAMETER_RX, DIAMETER_RX);                  //circle of RECEIVER
        smooth();
        
        

        int box_width = 10;
        for (int channel=0; channel<CH; channel++) {
          float a = (float)utility[n][channel];
          if (channel == 0) {
            fill(#FF0000, 150);
          } 
          else if (channel == 1) {
            fill(#4f9909, 150);
          } 
          else if (channel == 2) {
            fill(#4f99ff, 150);
          } 
          else if (channel == 3) {
            fill(#ff9900, 150);
          } 
          else if (channel == 4) {
            fill(#003366, 150);
          } 
          else if (channel == 5) {
            fill(#ffff00, 150);
          } 
          else if (channel == 6) {
            fill(#ff66ff, 150);
          } 
          else if (channel == 7) {
            fill(#330099, 150);
          }

          if (utility[n][channel]==0) {
            rect(int(AX[n])+(channel-CH/2)*box_width, int(AY[n]), box_width, (-40));
          }

          else if (utility[n][channel]!=0) {
            rect(int(AX[n])+(channel-CH/2)*box_width, int(AY[n]), box_width, 2*(log(abs(a))));
          }
        }
      }

    output.println (iteration + "\t" + player + "\t" +"\t" + BEST_CHANNEL + "\t"  + MAX_UTILITY + "\t" + SINR[player] + "\t" + THROUGHPUT[player] + "\t" + network_throughput_final[player] + "\t" + "\t" + potential_function_final [player]);
    output.flush();     // Write the remaining data
    iteration=iteration+1; 
    }
  }
  output.close();     // Finish the file
  //exit();
}