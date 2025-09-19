program rampLogic

double currentVoltage;
double targetVoltage;
double stepSize;
float interval;
double startCharge;
double HVset;
double voltageMonitorScan;
double voltageMonitorDelay;
double minStepSize;
short Prec; //precision for stopping ramping

assign currentVoltage to "{P}{R}OutputVget"; //change $(P)$(R) syntax
assign targetVoltage to "{P}{R}desiredHV";
assign stepSize to "{P}{R}VRAMPstepSize";
assign interval to "{P}{R}VRAMPinterval";
assign startCharge to "{P}{R}VRAMPactive";
assign HVset to "{P}{R}HVset";
assign voltageMonitorScan to "{P}{R}voltageMonitor.SCAN";
assign voltageMonitorDelay to "{P}{R}voltageMonitor.DLY1";
assign minStepSize to "{P}{R}minStepSize"; 
assign Prec to "{P}{R}C_Precision";

monitor currentVoltage;
monitor targetVoltage;
monitor stepSize;
monitor interval;
monitor startCharge;
monitor minStepSize;

ss RampState{

    state initial{/* decides rampup or rampdown once started- can maybe be merged w initial??*/
        when (startCharge == 1 && currentVoltage<targetVoltage){
        } state RampUp
        when (startCharge == 1 && currentVoltage>targetVoltage){
        } state RampDown
        when (startCharge == 0 || currentVoltage==targetVoltage){
        } state initial
    }

    state RampUp{
        when (currentVoltage < targetVoltage-prec  && startCharge == 1){ //***
            if (currentVoltage + stepSize < targetVoltage-minStepSize)
            { //ramp up
                HVset = currentVoltage += stepSize;
                pvPut(HVset);
            }
            else if  (currentVoltage + stepSize >= targetVoltage-minStepSize)
            { //final step
                HVset = targetVoltage;
                pvPut(HVset);
            }
        } state RampupDelay 

        when (currentVoltage >= targetVoltage-prec || startCharge == 0){ //stops ramping and returns to initial
            startCharge = 0;
            //"scan" menu represents 1 second as "6" so this sets to scan normally again (1 second)
            voltageMonitorScan = 6;
            voltageMonitorDelay = 0;
            pvPut(voltageMonitorScan);
            pvPut(voltageMonitorDelay);
            pvPut(startCharge);
        } state initial
    }

    state RampupDelay{ // delays by interval time
        when (delay(interval)){
        } state RampUp
    }

    state RampDown{ //sort out how youre gonna do negatives!!!!
        when (currentVoltage>targetVoltage+prec && startCharge == 1){ 
            if (currentVoltage - stepSize > targetVoltage+minStepSize){ //ramp down
                HVset = currentVoltage -= stepSize;
                pvPut(HVset);
            }
            else if  (currentVoltage - stepSize <= targetVoltage+minStepSize){ //final step
                HVset = targetVoltage;
                pvPut(HVset);
            }
        } state RampDownDelay 

        when (currentVoltage<=targetVoltage+prec || startCharge == 0){ //stops ramping and returns to initial
            startCharge = 0;
            voltageMonitorScan = 6;
            voltageMonitorDelay = 0;
            pvPut(voltageMonitorScan);
            pvPut(voltageMonitorDelay);
            pvPut(startCharge);
        } state initial
    }   
    state RampDownDelay{ // delays by interval time
        when (delay(interval)){
        } state RampDown
    }
}

