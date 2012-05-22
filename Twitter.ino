#include <string.h>

p_message twitter_search_message[]="Searching Twitter..\n";
p_message twitter_connect_message[]="connected\n";
p_message twitter_connect_failed_message[]="Connection failed\n";
p_message twitter_disconnect_message[]="disconnecting\n";
p_message twitter_resolving_message1[]="Resolving: ";
p_message twitter_resolving_message2[]=" ...\n";
p_message twitter_timeout_message[]="Timed out!\n";
p_message twitter_not_found_message[]="Not found!\n";
p_message twitter_error_message[]="Failed with error: ";
p_message twitter_found_message[]="Found Tweet ";
p_message twitter_seen_message[]="Seen Tweet ";

const char twitter_search[] = "search.twitter.com";
uint8_t twitter_search_ip[4] ={199,59,148,201};

#define TWITTER_ID_LENGTH 32
char lastID[TWITTER_ID_LENGTH];
char currentID[TWITTER_ID_LENGTH];

p_message http_preamble[] = "GET /search.atom?rpp=1&q=";
p_message http_second[] = "&since_id=";
p_message http_end[] = " HTTP/1.1\nHost: search.twitter.com\nConnection: close\n";

char falseChar = '~';                       //This is the charachter returned if a test is False 
                                            //(use a charachter you will not encounter) 
long timeout = 6000;   //This is the number of repeats run before a timeout is assummed
                       //The way it is implemented this is also the charachter limit for the
                      //webpage you are requesting
                      char id[] = "id>tag:search.twitter.com,2005:"; //The leading charachters to omit from the ID 
//(will have issues with overflowing)


void setupTwitter() {
  for (int i=0; i<TWITTER_ID_LENGTH; i++) {
    lastID[i]=0;
    currentID[i]=0;
  }
}

//////////////////////////
//  Connects to Twitter Search and sends a search request
//////////////////////////
int startSearchTwitter(char* term){
  printProgStr(twitter_search_message);
  EthernetClient client;

  if (client.connect(twitter_search, 80)) {
    printProgStr(twitter_connect_message);
    printProgStr(http_preamble);
    sendProgStr(&client,http_preamble);
    Serial.print(term);
    client.print(term);
    printProgStr(http_second);
    sendProgStr(&client,http_second);
    Serial.print(currentID);
    client.print(currentID);
    printProgStr(http_end);
    sendProgStr(&client,http_end);
    client.println();
    return processSearchTwitter(&client);
  } 
  else {
    printProgStr(twitter_connect_failed_message);
    return 0;
  } 
}






//////////////////////////
//  Iterates through the returned XML
//////////////////////////
int processSearchTwitter(EthernetClient* client){
  int idCount = 0;                             //how many IDs have we encoutered?


  ///////////////////////////////////////
  //---bof-- XML Parsing
  ///////////////////////////////////////
  if (client->connected()) {                   //If there is available data
    char c=0;
    while (client->connected()) {

      c = readNext(client);                 //Read the next charachter into memory

      //ID ID ID ID ID////////////////////////////////////
      ///////Test to see if the ID Tag has been opened
      ///////////////////////////////////////////////////
      char cc = testXMLTag(client, c, id, strlen(id));   //Test the ID tag
      if(cc != falseChar){                               //if the ID tag has been found, a non false charachter will be returned and we move into loading the d
          loadID(client, cc);                   //We pass the charachter to a routine that reads all the charachters of the ID number and turns it into an unisgmn
          if(strcmp(currentID,lastID)){                       //If the newly discovered ID is greater than the ID of the last tweet we typed
            idCount++;                             //we have found a tweet
            strcpy(lastID,currentID);                           //set this tweets ID as the new ID
            printProgStr(twitter_found_message);
            Serial.println(lastID);
          } else {
            printProgStr(twitter_seen_message);
            Serial.println(currentID);
          }
      }
      ///////////////////////////////////////
      //---eof-- XML Parsing
      ///////////////////////////////////////
    }
    Serial.println('.');
    client->stop();
  }

  return idCount;
}

//////////////////////////
//  Test to see if a XML Tag has been encountered (testString is the tag we searching for) will return a false charachter if not encountered
//  or the next charachter in the buffer if it has been encountered
//  (not a very good implementation as all charachters tested must be unique (ie no two tags in the same search sequence can start with the same charachter)
//////////////////////////


char testXMLTag(EthernetClient* client,char c, char* testString, int length){
  for(int i = 0; i < length && client->connected(); i++){  //iterate through the length of the test string
    if(c == testString[i]){           //If the current charachter matches the charachter at index i 
      c = readNext(client);        //read the next charachter to test 
    }
    else{                             //If it doesn't match
      return falseChar;                //Stop testing
    }
  }
  if (c==-1) {
    return falseChar;
  } else {
    return c;                 //return a false charachter if the tag has not been found or the next charachter in the buffer if it has been found
  }
}

//////////////////////////
//  Once an ID tag has been encountered the buffer gets sent here this will read the next 8 charachters and convert them into
//  an unsigned long
//////////////////////////
void loadID(EthernetClient* client, char c) {
  Serial.write('#');
  long tempLastID = 0;                              //Start at zero
  for (int i=0; c>='0' && c<='9' && i < TWITTER_ID_LENGTH-1 && client->connected();i++) {                      //read all numbers
    Serial.write(c);
    currentID[i]=c;
    currentID[i+1]=0;
    c = readNext(client);                              //Move to the next charachter
  }
  Serial.println('#');
}

char readNext(EthernetClient* client) {
  //wait for a character
  while(!client->available()) {
    if (!client->connected()) {
      return -1;
    }
  }
  char result = client->read();
  if (result == EOF) {
    client->stop();
    return -1;
  } else {
    return result;
  }
}


