#include <Metro.h>
#include <SPI.h>
#include <Ethernet.h>
#include <avr/pgmspace.h>
#define p_message const prog_char PROGMEM

////////////////////////////////////////////////////////////
///              MAIN CONFIGURATION                      ///
////////////////////////////////////////////////////////////

// the media access control (ethernet hardware) address for the shield:
//  (just needs to be different for each twit balloon in the network)
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xEF };  
//what to search for
char* search_term ="du";
//how much turns is it to the top, please include a .0 at the end
#define MAX_TURNS 35.0
//how much is the value of a tweet if the balloon stays on top reduce, if the balloon goaes down to fast increase
#define TWEET_WEIGHT 2000

/////////////////////////////////////////////////////////////


int targetCount = 0;

int currentCount = 0;


//we want to request ever 30 seconds
Metro twitterMetro = Metro(15l*1000l,1);
//the first time we search anyway
boolean first_search=true;
//we update once a second
Metro updateMetro = Metro(1000,1);

void setup()
{
  Serial.begin(9600);
  Serial.println(F("starting balloon"));
  setupBalloon();
  Serial.println(F("starting network"));
  setupNetwork();
  Serial.println(F("starting twitter"));
  setupTwitter();
  Serial.println(F("and done")); 
}

float twitter_count = 0;
int servo_level = 0;
char buf[2];

void loop()
{
  if (first_search || twitterMetro.check()) {
    first_search=false;
      char answers= startSearchTwitter(search_term);
      addAnswerToBalloon(answers);
  }
  loopBalloon();
}

int freeRam () {
  extern int __heap_start, *__brkval; 
  int v; 
  return (int) &v - (__brkval == 0 ? (int) &__heap_start : (int) __brkval); 
}







