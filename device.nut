// squirrel
imp.configure("getInfo setPins", [], []);
mypin <- hardware.pin1;

hardware.pin1.configure(DIGITAL_OUT);
hardware.pin2.configure(DIGITAL_OUT);
server.log("Device started");

function setPins(jsonobject) {
    setDigitalPin(0,jsonobject.hardware.pin[0]);
    setDigitalPin(1,jsonobject.hardware.pin[1]);
    
    agent.send("callback", {
        "callback": "getInfo",
        "mseconds_since_boot":  hardware.millis(),
        "wakereason": hardware.wakereason(),
        "hardware": { 
            "pin": [ hardware.pin1.read(), hardware.pin2.read() ],
            "voltage":  hardware.voltage()
            }
        } 
    );
}

function setDigitalPin(Pinnumber, DigitalValue) {
    if (Pinnumber==0) {
        if (hardware.pin1.read()!=DigitalValue)
            hardware.pin1.write(DigitalValue);
    }
    if (Pinnumber==1) {
        if (hardware.pin2.read()!=DigitalValue)
            hardware.pin2.write(DigitalValue);
    }
}

function getInfo(params) {
    server.log("device::getInfo() called");
    agent.send("callback", {
        "callback": "getInfo",
        "mseconds_since_boot":  hardware.millis(),
        "wakereason": hardware.wakereason(),
        "hardware": { 
            "pin": [ hardware.pin1.read(), hardware.pin2.read() ],
            "voltage":  hardware.voltage()
            }
        } 
    );
}
// register a handler for "led" messages from the agent
agent.on("getInfo", getInfo);
agent.on("setPins", setPins);

