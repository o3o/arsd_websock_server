import std;
import arsd.cgi;

void main()
{
    writeln("Listening on port 8080");
    //processPoolSize = 1;

   RequestServer server;
   server.listeningPort = 8080;
   server.serve!(websocketEcho, Cgi, defaultMaxContentLength)();

    //cgiMainImpl!((cgi) { websocketEcho(cgi); }, Cgi, defaultMaxContentLength)(["--port", "8080"]);
}

void websocketEcho(Cgi cgi) {
    assert(cgi.websocketRequested(), "i want a web socket!");
    auto websocket = cgi.acceptWebsocket();

    try
    {
        while(websocket.recvAvailable(300.seconds))
        {
            auto msg = websocket.recv();
            writeln(msg);

            if (msg.opcode == WebSocketOpcode.close) break;
            websocket.send(msg.data);

        }
        websocket.close();
    }
    catch(ConnectionClosedException e)
    {
        writeln("[Warning] Client disconnect detected");
    }
}
