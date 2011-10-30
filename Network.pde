#include <EthernetDHCP.h>
#include <EthernetDNS.h>

p_message obtaining_message[]="Obtaining DHCP lease...\n";
p_message ip_address_message[]="IP Address: ";
p_message gateway_message[]="Gateway: ";
p_message dns_server_message[]="DNS Server: ";

uint8_t mac[] = { 
  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };

//we want to renew the dns every 30 minutes

char setupNetwork() {
  char status=0;
  status = obtainDHCPLease();
  if (status<0) {
    return -1;
  }
  startDNS();
}

void loopNetwork()
{
  // You should periodically call this method in your loop(): It will allow
  // the DHCP library to maintain your DHCP lease, which means that it will
  // periodically renew the lease and rebind if the lease cannot be renewed.
  // Thus, unless you call this somewhere in your loop, your DHCP lease might
  // expire, which you probably do not want :-)
  EthernetDHCP.maintain();
}

char obtainDHCPLease() {
  printProgStr(obtaining_message);

  // Initiate a DHCP session. The argument is the MAC (hardware) address that
  // you want your Ethernet shield to use. This call will block until a DHCP
  // lease has been obtained. The request will be periodically resent until
  // a lease is granted, but if there is no DHCP server on the network or if
  // the server fails to respond, this call will block forever.
  // Thus, you can alternatively use polling mode to check whether a DHCP
  // lease has been obtained, so that you can react if the server does not
  // respond (see the PollingDHCP example).
  EthernetDHCP.begin(mac);

  // Since we're here, it means that we now have a DHCP lease, so we print
  // out some information.
  const byte* ipAddr = EthernetDHCP.ipAddress();
  const byte* gatewayAddr = EthernetDHCP.gatewayIpAddress();
  const byte* dnsAddr = EthernetDHCP.dnsIpAddress();

  printProgStr(ip_address_message);
  printIP(ipAddr);

  printProgStr(gateway_message);
  printIP(gatewayAddr);

  printProgStr(dns_server_message);
  printIP(dnsAddr);
  return 0;
}


void startDNS() {  
  // You will often want to set your own DNS server IP address (that is
  // reachable from your Arduino board) before doing any DNS queries. Per
  // default, the DNS server IP is set to one of Google's public DNS servers.
  EthernetDNS.setDNSServer(EthernetDHCP.dnsIpAddress());
}



