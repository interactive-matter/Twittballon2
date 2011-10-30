#include <Ethernet.h>
#include <Metro.h>
#include <SPI.h>

#include <avr/pgmspace.h>
#define p_message const prog_char PROGMEM

#define TURNS_PER_TWEET 1

void printIp(const uint8_t*);

p_message answer_message[] = "Answers: ";
p_message level_message[] = "Level: ";


char* search_term ="sonne";
int targetCount = 0;

int currentCount = 0;


//we want to request ever 30 seconds
Metro twitterMetro = Metro(30l*1000l,1);
//we update once a second
Metro updateMetro = Metro(1000,1);

void setup()
{
  Serial.begin(9600);
  Serial.println(freeRam());
  setupBalloon();
  Serial.println(freeRam());
  setupNetwork();
  Serial.println(freeRam());
  char current_tweets = searchTwitter(search_term);
}

float twitter_count = 0;
int servo_level = 0;
char buf[2];

void loop()
{
  loopNetwork();
  char answers= searchTwitterForAnswers();
  loopBalloon(answers);
}

int freeRam () {
  extern int __heap_start, *__brkval; 
  int v; 
  return (int) &v - (__brkval == 0 ? (int) &__heap_start : (int) __brkval); 
}





