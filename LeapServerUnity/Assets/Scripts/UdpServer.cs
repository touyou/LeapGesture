using System.Text;
using System.Net;
using System.Net.Sockets;
using System.Threading;

public class UdpServer {
  private UdpClient udpForSend;
  private string remoteHost = "localhost";
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
    } catch { }
  }

  public void end() {
    try {
      udpForSend.Close();
    } catch { }
  }
}
