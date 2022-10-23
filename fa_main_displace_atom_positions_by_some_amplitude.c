#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(int argc, char** argv){

  int N = atoi(argv[1]); // Number of particles to displace
  double A = atof(argv[2]); // Max amplitude to displace

  time_t t;
  srand((unsigned) time(&t));

  for(int i = 0; i < N ; i++)
  printf("%lf %lf %lf \n", (-1 + 2*(double) rand()/RAND_MAX)*A, (-1 + 2*(double) rand()/RAND_MAX)*A, (-1 + 2*(double) rand()/RAND_MAX)*A );


  return 0;

}

