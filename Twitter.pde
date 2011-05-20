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

const char twitter_search[] = "stream.twitter.com";
uint8_t twitter_search_ip[4];

Client client(twitter_search_ip, 80);

char decodeAnswer(char* answer);

char* searchquery;

char last_id[16]="0";
//http://stream.twitter.com/1/statuses/filter.json?track=json
p_message http_preamble[] = "GET /1/statuses/filter.json?track=";
p_message http_end[] = " HTTP/1.1\nHost: stream.twitter.com\nAccept: application/json\nAuthorization: Basic cGFsb2FsdG9uYWxlOmdvb2RsYWNr\n\n";

char searchTwitter(char* query) {
  lookupHosts();
  printProgStr(twitter_search_message);
  searchquery = query;
}

char searchTwitterForAnswers() {
  char answers = -1;
  if (!client.connected()) {
    if (client.connect()) {
      printProgStr(twitter_connect_message);
      printProgStr(http_preamble);
      sendProgStr(&client,http_preamble);
      Serial.print(searchquery);
      client.print(searchquery);
      printProgStr(http_end);
      sendProgStr(&client,http_end);
      client.println();
    } 
    else {
      printProgStr(twitter_connect_failed_message);
      return 0;
    }
  }
  unsigned int pos = 0;            
  //ok we are conected it seems
  while(client.available() && pos<TWITTER_MAX_LENGTH) {
    char c = client.read();
    //Serial.print(c);
    querybuffer[pos]=c;
    pos++;
  }
  querybuffer[pos]=0;
  //Serial.print(querybuffer);
  answers = decodeAnswer(querybuffer);
  if (answers>0) {
    Serial.print("answers: ");
    Serial.println(answers,DEC);
  }
  return answers;
}


const char* id_pattern = "\"text\"";
char decodeAnswer(char* answer) {
  unsigned char count = 0;
  char* id_tok = strstr(answer,id_pattern);
  while (id_tok!=NULL) {
    count++;
    id_tok = strstr(id_tok+1,id_pattern);
  }
  return count;    
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







