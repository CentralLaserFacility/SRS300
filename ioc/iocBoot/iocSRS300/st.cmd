#!../../bin/linux-x86_64/SRS300

#- You may have to change SRS300 to something else
#- everywhere it appears in this file

< envPaths

# LANTRONIX RS232 adapter address
#
epicsEnvSet("MODEL","$(MODEL=370)")
epicsEnvSet("ADDR","192.168.0.20:10002")
epicsEnvSet("A","-1")
epicsEnvSet("PORT","L0")

epicsEnvSet("STREAM_PROTOCOL_PATH", "${TOP}/proto") 

# PV name prefix
#
epicsEnvSet("PREFIX","BENCH:")
epicsEnvSet("SUFFIX","HVPS:")

cd "${TOP}"

## Register all support components
dbLoadDatabase "dbd/SRS300.dbd"
SRS300_registerRecordDeviceDriver pdbbase

drvAsynIPPortConfigure("L0","$(ADDR)",0,0,0)

## Load record instances
dbLoadRecords("$(ASYN)/db/asynRecord.db","P=$(PREFIX)$(SUFFIX),R=asyn,PORT=$(PORT),ADDR=0,OMAX=256,IMAX=256")
dbLoadTemplate("db/devSRS_PS3xx.substitutions","PORT=$(PORT),R=$(SUFFIX),P=$(PREFIX),A=$(A), MODEL=$(MODEL)")
dbLoadRecords("db/devSRS_PS300_common.db","P=$(PREFIX),R=$(SUFFIX),L=0,A=$(A)")

#dbLoadRecords("$(TOP)/db/devSRS_PS375.db","P=$(PREFIX),R=$(SUFFIX),PORT=$(PORT),A=$(A)")
#dbLoadTemplate("db/devSRS_PSxxx.substitutions","PORT=$(PORT),A=$(A)")

cd "${TOP}/iocBoot/${IOC}"

#Commence IOC running
iocInit

stringiftest("NEGPOLARITY", "$(MODEL=370)", 5, "YES")
$(IFNEGPOLARITY) < setNegativePolarity.cmd

## Start any sequence programs
seq &rampLogic, "P=$(PREFIX),R=$(SUFFIX),L=0,A=$(A)"

