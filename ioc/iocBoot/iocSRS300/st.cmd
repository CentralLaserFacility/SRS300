#!../../bin/linux-x86_64/SRS300

#- You may have to change SRS300 to something else
#- everywhere it appears in this file

< envPaths

epicsEnvSet("MODEL","$(MODEL=370)")
epicsEnvSet("PORT","L0")

# LANTRONIX RS232 adapter address + macros
#
# epicsEnvSet("ADDR","192.168.0.20:10002")
# epicsEnvSet("A","-1")
# epicsEnvSet("SCANRATE", ".1 second")
# epicsEnvSet("READ", "GET")
#

# GPIB adapter address + macros
#
epicsEnvSet("ADDR","192.168.1.50:1234")
epicsEnvSet("A","14")
epicsEnvSet("SCANRATE", ".2 second")
epicsEnvSet("READ", "SCAN")
#

epicsEnvSet("STREAM_PROTOCOL_PATH", "${TOP}/proto") 

# PV name prefix
#
epicsEnvSet("DEVICE","VUL-TEST-PS300-1")

cd "${TOP}"

## Register all support components
dbLoadDatabase "dbd/SRS300.dbd"
SRS300_registerRecordDeviceDriver pdbbase


drvAsynIPPortConfigure("$(PORT)","$(ADDR)",0,0,0)


# asynSetTraceMask("$(PORT)", 0, 0x09)
# asynSetTraceIOMask("$(PORT)", 0, 0x02)


## Load record instances
dbLoadRecords("$(ASYN)/db/asynRecord.db","P=$(DEVICE):, R=asyn,PORT=$(PORT),ADDR=0,OMAX=256,IMAX=256")
dbLoadRecords("db/devSRS_PS3xx.db","PORT=$(PORT),DEVICE=$(DEVICE), A=$(A), MODEL=$(MODEL), SCANRATE=$(SCANRATE), READ=$(READ)")
dbLoadTemplate("db/devSRS_PS3xx.substitutions","PORT=$(PORT),DEVICE=$(DEVICE), A=$(A), MODEL=$(MODEL)")
dbLoadRecords("db/devSRS_PS3xx_ui.db","PORT=$(PORT),DEVICE=$(DEVICE), A=$(A), MODEL=$(MODEL)")
dbLoadRecords("db/devSRS_PS3xx_ramp.db","PORT=$(PORT),DEVICE=$(DEVICE), A=$(A), MODEL=$(MODEL)")
dbLoadRecords("db/customLimits.db","PORT=$(PORT),DEVICE=$(DEVICE), A=$(A), MODEL=$(MODEL)")
dbLoadRecords("db/devSRS_PS300_common.db","DEVICE=$(DEVICE), L=0,A=$(A)")

# specify where save files should go
set_savefile_path("$(TOP)/autoSaveRestore")

## specify where request files can be found
# current directory 
set_requestfile_path("$(TOP)/autoSaveRestore")
# specify where request files can be found
set_requestfile_path("$(AUTOSAVE)/asApp/Db/")

dbLoadRecords("$(AUTOSAVE)/db/configMenu.db","P=$(DEVICE):,CONFIG=ramp1")
save_restoreSet_DatedBackupFiles(0)
set_pass0_restoreFile("ramp1Menu.sav", "P=$(DEVICE):,CONFIG=ramp1,CONFIGMENU=1")
set_pass1_restoreFile("ramp1Menu.sav", "P=$(DEVICE):,CONFIG=ramp1,CONFIGMENU=1")



cd "${TOP}/iocBoot/${IOC}"

#Commence IOC running
iocInit

create_monitor_set("ramp1Menu.req", 5 , "P=$(DEVICE):, CONFIG=ramp1,CONFIGMENU=1")


## Start any sequence programs
seq &rampLogic, "DEVICE=$(DEVICE),L=0,A=$(A)"

