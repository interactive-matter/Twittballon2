
// given a PROGMEM string, use Serial.print() to send it out
// this is needed to save precious memory
//htanks to todbot for this http://todbot.com/blog/category/programming/
void printProgStr(const prog_char* str) {
  char c;
  if (!str) {
    return;
  }
  while ((c = pgm_read_byte(str))) {
    Serial.write(c);
    str++;
  }
}

// given a PROGMEM string, use Serial.print() to send it out
// this is needed to save precious memory
//htanks to todbot for this http://todbot.com/blog/category/programming/
void sendProgStr(Client* client, const prog_char* str) {
  char c;
  if (!str) {
    return;
  }
  while ((c = pgm_read_byte(str))) {
    client->print(c);
    str++;
  }
}

// Just a utility function to nicely format an IP address.
const void printIP(const uint8_t* ipAddr)
{
  Serial.print(ipAddr[0],DEC);
  Serial.print('.');
  Serial.print(ipAddr[1],DEC);
  Serial.print('.');
  Serial.print(ipAddr[2],DEC);
  Serial.print('.');
  Serial.println(ipAddr[3],DEC);
}


