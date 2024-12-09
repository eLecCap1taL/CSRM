"use strict";

const http = require("http");

const port = 3000;
const host = "127.0.0.1";

const server = http.createServer(function (req, res) {
  if (req.method == "POST") {
    console.log("Handling POST request...");
    res.writeHead(200, { "Content-Type": "text/html" });

    let body = "";
    req.on("data", function (data) {
      body += data;
    });
    req.on("end", function () {
      console.log("POST payload: " + body);
      res.end("");
    });
  } else {
    console.log("Not expecting other request types...");
    res.writeHead(200, { "Content-Type": "text/html" });
    let html =
      "<html><body>HTTP Server at http://" +
      host +
      ":" +
      port +
      "</body></html>";
    res.end(html);
  }
});

server.listen(port, host);
console.log("Listening at http://" + host + ":" + port);