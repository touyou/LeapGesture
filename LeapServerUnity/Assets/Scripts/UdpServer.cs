using System.Text;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using UnityEngine;

public class UdpServer {
  private UdpClient udpForSend;
  private string remoteHost = "192.168.111.105";
  private int remotePort;

  public UdpServer() { }

  public bool init(int port_snd, int port_to) {
    try {
      udpForSend = new UdpClient(port_snd);
      remotePort = port_to;
      return true;
    } catch {
      return false;
    }
  }

  public void send(string sendMsg) {
    try {
      byte[] sendBytes = Encoding.UTF8.GetBytes(sendMsg);
      udpForSend.Send(sendBytes, sendBytes.Length, remoteHost, remotePort);
      Debug.Log(sendBytes);
    } catch { }
  }

  public void end() {
    try {
      udpForSend.Close();
    } catch { }
  }
}
