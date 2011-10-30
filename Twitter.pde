#include <string.h>
#define TWITTER_MAX_LENGTH 1024
char querybuffer[TWITTER_MAX_LENGTH];

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
uint8_t twitter_search_ip[4];

Client client(twitter_search_ip, 80);
p_message http_preamble[] = "GET /search.atom?rpp=1&q=";
p_message http_second[] = "&since_id=";
p_message http_end[] = " HTTP/1.1\nHost: search.twitter.com\n";

char falseChar = '~';                       //This is the charachter returned if a test is False 
                                            //(use a charachter you will not encounter) 
long timeout = 3000;   //This is the number of repeats run before a timeout is assummed
                       //The way it is implemented this is also the charachter limit for the
                      //webpage you are requesting
                      char id[] = "id>tag:search.twitter.com,2005:"; //The leading charachters to omit from the ID 
//(will have issues with overflowing)


//last Id we have seen
unsigned long lastID = 0;

//////////////////////////
//  Connects to Twitter Search and sends a search request
//////////////////////////
void startSearchTwitter(char* term){
  printProgStr(twitter_search_message);
  lookupHosts();

  if (client.connect()) {
    printProgStr(twitter_connect_message);
    printProgStr(http_preamble);
    sendProgStr(&client,http_preamble);
    Serial.print(term);
    client.print(term);
    printProgStr(http_second);
    sendProgStr(&client,http_second);
    Serial.print(lastID);
    client.print(lastID);
    printProgStr(http_end);
    sendProgStr(&client,http_end);
    client.println();
  } 
  else {
    printProgStr(twitter_connect_failed_message);
  } 
}






//////////////////////////
//  Iterates through the returned XML
//////////////////////////
int processSearchTwitter(){
  int idCount = 0;                             //how many IDs have we encoutered?


  ///////////////////////////////////////
  //---bof-- XML Parsing
  ///////////////////////////////////////
  if (client.connected()) {                   //If there is available data
    boolean printTweet = false;               //by default we will not print the returned tweet (later we check if it is newer than the last tweet
    char c=0;
    while (client.connected()) {

      c = client.read();                 //Read the next charachter into memory

      //ID ID ID ID ID////////////////////////////////////
      ///////Test to see if the ID Tag has been opened
      ///////////////////////////////////////////////////
      char cc = testXMLTag(client, c, id, sizeof(id));   //Test the ID tag
      if(cc != falseChar){                               //if the ID tag has been found, a non false charachter will be returned and we move into loading the d
          long tempLastID = loadID(c);                   //We pass the charachter to a routine that reads all the charachters of the ID number and turns it into an unisgmn
            if(tempLastID > lastID){                       //If the newly discovered ID is greater than the ID of the last tweet we typed
            idCount++;                             //we have found a tweet
            lastID = tempLastID;                           //set this tweets ID as the new ID
            printProgStr(twitter_found_message);
            Serial.println(lastID);
          } else {
                        printProgStr(twitter_seen_message);
            Serial.println(lastID);
          }
      }
      ///////////////////////////////////////
      //---eof-- XML Parsing
      ///////////////////////////////////////
    }
  }

      if (!client.connected()) {             //Disconnect the client
        Serial.println();
        Serial.println("disconnecting.");
        client.stop();
        //for(;;);
      }
  return idCount;
}

//////////////////////////
//  Test to see if a XML Tag has been encountered (testString is the tag we searching for) will return a false charachter if not encountered
//  or the next charachter in the buffer if it has been encountered
//  (not a very good implementation as all charachters tested must be unique (ie no two tags in the same search sequence can start with the same charachter)
//////////////////////////


char testXMLTag(Client client2, char c, char* testString, int length){
  char returnValue = falseChar;       //default the return charachter to the false charachter
  for(int i = 0; i < length-1; i++){  //iterate through the length of the test string
    if(c == testString[i]){           //If the current charachter matches the charachter at index i 
      c = client2.read();               //read the next charachter to test 
    }
    else{                             //If it doesn't match
      i = length;                       //Stop testing
    }

    if(i == length-2){                //If we have reached the length of the testString
      returnValue = c;                  //set the return value to the last read charachter
    }
  } 
  return returnValue;                 //return a false charachter if the tag has not been found or the next charachter in the buffer if it has been found
}

//////////////////////////
//  Once an ID tag has been encountered the buffer gets sent here this will read the next 8 charachters and convert them into
//  an unsigned long
//////////////////////////
long loadID(char c) {
  long tempLastID = 0;                              //Start at zero
  for(int i = 9; i >= 0; i--) {                      //iterate through the next 8 characheters (assumes an ID in the billion range
    int temp = (int)c-48;                           //convert the ASCii code to a number (ie. ASCII for '1' = 49)
    tempLastID = tempLastID + (temp * pow(10,i));   //Add the number to the appropriate power
    c = client.read();                              //Move to the next charachter
  }
  return tempLastID;                                //Return the discovered long
}


char lookupHosts() {
  printProgStr(twitter_resolving_message1);
  Serial.print(twitter_search);
  printProgStr(twitter_resolving_message2);

  // Resolve the host name and block until a result has been obtained.
  // This means that the call will not return until a result has been found
  // or the query times out. While it is less effort to write a query this
  // way, the problem is that the whole sketch will "hang", which might not
  // be what you want. If you want to retain control over the sketch while
  // the query is being processed, check out the PollingDNS example.
  DNSError err = EthernetDNS.resolveHostName(twitter_search, twitter_search_ip);

  // Finally, we have a result. We're just handling the most common errors
  // here (success, timed out, not found) and just print others as an
  // integer. A full listing of possible errors codes is available in
  // EthernetDNS.h
  if (DNSSuccess == err) {
    printProgStr(ip_address_message);
    printIP(twitter_search_ip);
  } 
  else if (DNSTimedOut == err) {
    printProgStr(twitter_timeout_message);
  } 
  else if (DNSNotFound == err) {
    printProgStr(twitter_not_found_message);
  } 
  else {
    printProgStr(twitter_error_message);
    Serial.println((int)err, DEC);
  }
}





