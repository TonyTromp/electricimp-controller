// configure the imp (best practice)
imp.configure("getInfo setPins", [], []);
mypin <- hardware.pin1;

hardware.pin1.configure(DIGITAL_OUT);
hardware.pin2.configure(DIGITAL_OUT);
server.log("Device started");

function setPins(jsonobject) {
    server.log("SetPins");
    for (local i=0;i<(jsonobject.hardware.pin.len());i++) {
        server.log(i);
        setDigitalPin(i,jsonobject.hardware.pin[i]);        
    }
    
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
    
    if ((Pinnumber==0)&&(hardware.pin1.read()!=DigitalValue)) {
        server.log("pin1 changed");
        hardware.pin1.write(DigitalValue);
    }
    if ((Pinnumber==1)&&(hardware.pin2.read()!=DigitalValue)) {
        server.log("pin2 changed");
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

