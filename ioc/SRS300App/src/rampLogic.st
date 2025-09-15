program rampLogic

double currentVoltage;
double targetVoltage;
double stepSize;
float interval;
double startCharge;
double HVset;

assign currentVoltage to "{P}{R}OutputVget"; //change $(P)$(R) syntax
assign targetVoltage to "{P}{R}desiredHV";
assign stepSize to "{P}{R}VRAMPstepSize";
assign interval to "{P}{R}VRAMPinterval";
assign startCharge to "{P}{R}VRAMPactive";
assign HVset to "{P}{R}HVset";

monitor currentVoltage;
monitor targetVoltage;
monitor stepSize;
monitor interval;
monitor startCharge;

ss RampState{
    state initial{ /*waiting for startCharge to be pressed*/
        when (startCharge == 1){
        } state init
        when (startCharge == 0){
        } state initial
    }

    state init{/* decides rampup or rampdown once started- can maybe be merged w initial??*/
        when (startCharge == 1 && currentVoltage<targetVoltage){
        } state RampUp
        when (startCharge == 1 && currentVoltage>targetVoltage){
        } state RampDown
        when (startCharge == 0 || currentVoltage==targetVoltage){
        } state initial
    }

    state RampUp{
        when (currentVoltage!=targetVoltage && startCharge == 1){ 
            if (currentVoltage + stepSize < targetVoltage-100)
            { //ramp up
                HVset = currentVoltage += stepSize;
                pvPut(HVset);
            }
            else if  (currentVoltage + stepSize >= targetVoltage-100)
            { //final step
                HVset = targetVoltage;
                pvPut(HVset);
            }
        } state RampupDelay 

        when (currentVoltage==targetVoltage || startCharge == 0){ //stops ramping and returns to initial
            startCharge = 0;
            pvPut(startCharge);
        } state initial
    }

    state RampupDelay{ // delays by interval time
        when (delay(interval)){
        } state RampUp

    }

    state RampDown{ //sort out how youre gonna do negatives!!!!
        when (currentVoltage!=targetVoltage && startCharge == 1){ 
            if (currentVoltage - stepSize > targetVoltage+100){ //ramp down
                HVset = currentVoltage -= stepSize;
                pvPut(HVset);
            }
            else if  (currentVoltage - stepSize <= targetVoltage+100){ //final step
                HVset = targetVoltage;
                pvPut(HVset);
            }
        } state RampDownDelay 

        when (currentVoltage==targetVoltage || startCharge == 0){ //stops ramping and returns to initial
            startCharge = 0;
            pvPut(startCharge);
        } state initial
    }   
    state RampDownDelay{ // delays by interval time
        when (delay(interval)){
        } state RampDown
    }
}

