import ballerina/log;
import ballerina/websocket;

// WebSocket Service for notifications
@websocket:ServiceConfig {}
service /notify on new websocket:Listener(8082) {
    // Function to handle WebSocket connection open event
    resource function get .() returns websocket:Service {
        log:printInfo("New WebSocket connection established.");
        return new WsService();
    }
}

service class WsService {
    *websocket:Service;

    // Function to handle incoming text messages from clients
    remote function onMessage(websocket:Caller caller, string text) returns websocket:Error? {
        log:printInfo("Received alert: " + text);
        check caller->writeTextMessage("Danger alert: " + text);
    }

    // Function to handle WebSocket connection close
    remote function onClose(websocket:Caller caller, int statusCode, string reason) returns websocket:Error? {
        log:printInfo("Connection closed. Reason: " + reason);
    }
}
