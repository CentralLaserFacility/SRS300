program rampLogic
%%#define RAMPING 1
%%#define IDLE 0
%%#define REGULAR_SCAN 6 //regular scan = 1 second
//to change default scan see scan menu and change 6 accordingly
%%#define PASSIVE 0 // 0 = passive scanning
%%#define END 1 // 1 = ramp ended
%%#define SCAN_DELAY 1.45 //delay time for voltage to stabilize after setting new voltage
%%#define RAMP_UP 1
%%#define RAMP_DOWN 0

double presentVoltage;
double targetVoltage;
double stepSize;
double interval;
short startCharge;// 1 = ramping, 0 = Idle
double HVset;
short voltageMonitorScan; 
double minStepSize;
short Tolerance; //Tolerance for stopping ramping
double newVoltage;
short endCharge; // 1 = ramp ended, 0 = not ended
short rampDirection; // 1 = ramp up, 0 = ramp down
short monitorPROC;


assign presentVoltage to "{P}{R}OutputVget"; //change $(P)$(R) syntax
assign targetVoltage to "{P}{R}desiredHV";
assign stepSize to "{P}{R}VRAMPstepSize";
assign interval to "{P}{R}VRAMPinterval";
assign startCharge to "{P}{R}VRAMPactive";
assign HVset to "{P}{R}HVset";
assign voltageMonitorScan to "{P}{R}voltageMonitor.SCAN";
assign monitorPROC to "{P}{R}voltageMonitor.PROC";
assign minStepSize to "{P}{R}C_minStepSize"; 
assign Tolerance to "{P}{R}C_Tolerance";
assign endCharge to "{P}{R}endCharge";

monitor presentVoltage;
monitor targetVoltage;
monitor stepSize;
monitor interval;
monitor startCharge;
monitor minStepSize;
monitor Tolerance;

ss RampState{

    state initial{//stays idle then decides rampup or rampdown once started
        when (startCharge == RAMPING && presentVoltage<targetVoltage){
            //status scanning must be paused while voltage is being set
            rampDirection = RAMP_UP;
            voltageMonitorScan = PASSIVE;//set to passive scanning before ramping
            pvPut(voltageMonitorScan); 
        } state RampUp
        when (startCharge == RAMPING && presentVoltage>targetVoltage){
            rampDirection = RAMP_DOWN;
            voltageMonitorScan = PASSIVE;
            pvPut(voltageMonitorScan); 
        } state RampDown
        when (startCharge == IDLE || presentVoltage==targetVoltage){
        } state initial
    }

    state RampUp{
        when (presentVoltage < targetVoltage-Tolerance && startCharge == RAMPING){
            newVoltage = presentVoltage + stepSize;
            if (newVoltage > targetVoltage-minStepSize){ //safety check
                //if the next step is smaller than minStepSize, set straight to target instead
                newVoltage = targetVoltage;
            }
            HVset = newVoltage;
            pvPut(HVset);
        } state StableDelay 

        when (presentVoltage >= (targetVoltage-Tolerance) || startCharge == IDLE){ //stops ramping and returns to initial
            startCharge = IDLE;
            endCharge = END;
            pvPut(startCharge);
            pvPut(endCharge);
        } state initial
    }

    state RampDown{ 
        when (presentVoltage > targetVoltage+Tolerance && startCharge == RAMPING){
            newVoltage = presentVoltage - stepSize;
            if (newVoltage < targetVoltage+minStepSize){ //safety check
                //if the next step is smaller than minStepSize, set straight to target instead
                newVoltage = targetVoltage;
            }
            HVset = newVoltage;
            pvPut(HVset);
            
        } state StableDelay 

        when (presentVoltage<=(targetVoltage+Tolerance) || startCharge == IDLE){ //stops ramping and returns to initial
            startCharge = IDLE;
            endCharge = END;
            pvPut(startCharge);
            pvPut(endCharge);
        } state initial
    }

//_____states for delays_______
//_____________________________

    state StableDelay{ 
        when (delay(SCAN_DELAY)){// delays by 1.45 seconds to allow voltage to stabilize
            //set back to regular scanning while safe
            voltageMonitorScan = REGULAR_SCAN;
            pvPut(voltageMonitorScan);
            monitorPROC = 1; //force to update immediately after delay
            pvPut(monitorPROC);
        } state IntervalDelay
    }

    state IntervalDelay{ 
        when ((delay(interval-SCAN_DELAY)) && (rampDirection == RAMP_UP)){// delays by rest of interval time
            monitorPROC = 1; //force to update immediately before next ramp step
            pvPut(monitorPROC);
            voltageMonitorScan = PASSIVE;//set back to passive scanning before ramping
            pvPut(voltageMonitorScan);          
        } state RampUp

        when ((delay(interval-SCAN_DELAY)) && (rampDirection == RAMP_DOWN)){// delays by rest of interval time
            voltageMonitorScan = PASSIVE;//set back to passive scanning before ramping
            pvPut(voltageMonitorScan);            
        } state RampDown
    }
}

