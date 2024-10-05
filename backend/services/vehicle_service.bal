import ballerina/http;
import ballerina/log;

// Vehicle data type
type Vehicle record {
    string vehicleId;
    float latitude;
    float longitude;
    float speed;
    string road;
};

// Store vehicle data in a map
map<Vehicle> vehicleMap = {};

// HTTP Service for Vehicle Tracking
service /vehicle on new http:Listener(8080) {

    // POST request to receive and store vehicle data
    resource function post track(http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        Vehicle vehicle = check payload.cloneWithType(Vehicle);
        vehicleMap[vehicle.vehicleId] = vehicle; // Store vehicle data
        check caller->respond("Vehicle data received and stored.");
        log:printInfo("Vehicle Data Stored: " + vehicle.vehicleId);
    }

    // GET request to retrieve all vehicle data
    resource function get all(http:Caller caller, http:Request req) returns error? {
        Vehicle[] vehicleList = [];

        // Iterate over the map to get the vehicles
        foreach var vehicleId in vehicleMap.keys() {
            Vehicle? vehicle = vehicleMap[vehicleId]; // Safely access the vehicle
            if vehicle is Vehicle {
                vehicleList.push(vehicle); // Only push non-null vehicles
            }
        }

        check caller->respond(vehicleList);
    }
}
