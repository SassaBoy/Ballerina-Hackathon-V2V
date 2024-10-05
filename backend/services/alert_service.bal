import ballerina/http;
import ballerina/log;

// Define a structure for vehicle data
type VehicleData record {
    string vehicleId;
    float speed;
};

// Alert structure for high-speed vehicles
type Alert record {
    string vehicleId;
    string message;
};

// Speed threshold for alerts
const float SPEED_THRESHOLD = 120;

// Store alerts in an array (or map)
Alert[] alertList = [];

// HTTP Service for alerts
service /alert on new http:Listener(8081) {

    // POST request to check vehicle speed and add an alert if necessary
    resource function post checkSpeed(http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        VehicleData|error vehicle = payload.cloneWithType(VehicleData);

        if vehicle is error {
            log:printError("Failed to parse vehicle data", vehicle);
            check caller->respond("Error parsing vehicle data");
            return;
        }

        // Check the speed and generate an alert if needed
        if vehicle.speed > SPEED_THRESHOLD {
            Alert alert = {
                vehicleId: vehicle.vehicleId,
                message: "Vehicle " + vehicle.vehicleId + " is speeding at " + vehicle.speed.toString() + " km/h. Slow down!"
            };
            alertList.push(alert); // Add alert to the list
            log:printWarn(alert.message);
            check caller->respond(alert);
        } else {
            check caller->respond("No alert: Vehicle within safe speed.");
        }
    }

    // GET request to retrieve all alerts
    resource function get all(http:Caller caller, http:Request req) returns error? {
        check caller->respond(alertList); // Return all stored alerts
    }
}
