import ballerina/http;
import ballerina/lang.'string as strings;
import ballerina/log;
import ballerina/websocket;

// External services
final http:Client vehicleClient = check new ("http://localhost:8080");
final http:Client alertClient = check new ("http://localhost:8081");
final websocket:Client notificationClient = check new ("ws://localhost:8082/notify");

service /orchestrate on new http:Listener(8083) {
    // Orchestrate vehicle tracking and alerts
    resource function post trackAndAlert(http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();

        // Step 1: Send vehicle data to vehicle tracking service
        http:Response vehicleResp = check vehicleClient->post("/vehicle/track", payload);
        // Allow both 200 OK and 201 Created as success responses
        if (vehicleResp.statusCode != http:STATUS_OK && vehicleResp.statusCode != http:STATUS_CREATED) {
            log:printError("Error from vehicle tracking service. Status code: " + vehicleResp.statusCode.toString());
            check caller->respond("Error processing vehicle data");
            return;
        }
        log:printInfo("Vehicle data successfully sent to the vehicle tracking service.");

        // Step 2: Send vehicle data to alert service
        http:Response alertResp = check alertClient->post("/alert/checkSpeed", payload);
        string alertMessage = check alertResp.getTextPayload();

        // Step 3: Send alert to notification service if danger is detected
        if (strings:includes(alertMessage, "speeding")) {
            check notificationClient->writeTextMessage(alertMessage);
            log:printInfo("Notification sent: " + alertMessage);
        }

        // Respond to the client with the alert message
        check caller->respond(alertMessage);
    }
}
