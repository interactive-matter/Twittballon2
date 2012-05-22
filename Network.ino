
//the IP address for the shield:
byte ip[] = { 10, 0, 5, 9 };    
// the router's gateway address:
byte gateway[] = { 10, 0, 5, 1 };
// the subnet:
byte subnet[] = { 255, 255, 255, 0 };
//we want to renew the dns every 30 minutes

char setupNetwork() {
  char status=0;
  // start the Ethernet connection:
  Serial.println(F("Obtaining IP Address"));
  if (Ethernet.begin(mac) == 0) {
    Serial.println(F("Failed to configure Ethernet using DHCP"));
    // no point in carrying on, so do nothing forevermore:
    Ethernet.begin(mac,ip,gateway,subnet);
  }
  // print your local IP address:
  Serial.print(F("My IP address: "));
  for (byte thisByte = 0; thisByte < 4; thisByte++) {
    // print the value of each byte of the IP address:
    Serial.print(Ethernet.localIP()[thisByte], DEC);
    Serial.print(F(".")); 
  }
  Serial.println();
  
  if (status<0) {
    return -1;
  } else {
    return 0;
  }
}

