#include <Ethernet.h>
#include <Metro.h>
#include <SPI.h>
#include <Messenger.h>
#include <EthernetBonjour.h>
#include <Ciao.h>
#include <avr/pgmspace.h>
#define p_message const prog_char PROGMEM

////////////////////////////////////////////////////////////
///              MAIN CONFIGURATION                      ///
////////////////////////////////////////////////////////////

//what to search for
char* search_term ="sonne";
//how much turns is it to the top, please include a .0 at the end
#define MAX_TURNS 35.0
//how much is the value of a tweet if the balloon stays on top reduce, if the balloon goaes down to fast increase
#define TWEET_WEIGHT 100

/////////////////////////////////////////////////////////////


p_message answer_message[] = "Answers: ";
p_message level_message[] = "Level: ";


int targetCount = 0;

int currentCount = 0;


//we want to request ever 30 seconds
Metro twitterMetro = Metro(15l*1000l,1);
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
  setupTwitter();
  Serial.println(freeRam());
}

float twitter_count = 0;
int servo_level = 0;
char buf[2];

void loop()
{
  loopNetwork();
  if (twitterMetro.check()) {
    startSearchTwitter(search_term);
    delay(1000);                       //Waits a second for a response
    char answers= processSearchTwitter();
    addAnswerToBalloon(answers);
  }
  loopBalloon();
}

int freeRam () {
  extern int __heap_start, *__brkval; 
  int v; 
  return (int) &v - (__brkval == 0 ? (int) &__heap_start : (int) __brkval); 
}







