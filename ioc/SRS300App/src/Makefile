TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

#=============================
# Build the IOC application

PROD_IOC = SRS300
# SRS300.dbd will be created and installed
DBD += SRS300.dbd

# SRS300.dbd will be made up from these files:
SRS300_DBD += base.dbd

# Include dbd files from all support applications:
SRS300_DBD += calc.dbd sscan.dbd
SRS300_DBD += sscan.dbd
SRS300_DBD += utilities.dbd
SRS300_DBD += asyn.dbd
SRS300_DBD += stream.dbd
#ifdef FTDI
#SRS300_DBD += drvAsynSerialPort.dbd
#endif
SRS300_DBD += drvAsynIPPort.dbd
SRS300_DBD += asSupport.dbd

# Add all the support libraries needed by this IOC
#SRS300_LIBS += xxx
SRS300_LIBS += calc 
SRS300_LIBS += sscan 
SRS300_LIBS += asyn
SRS300_LIBS += stream
SRS300_LIBS += autosave
SRS300_LIBS += utilities
SRS300_SYS_LIBS += pcre

# SRS300_registerRecordDeviceDriver.cpp derives from SRS300.dbd
SRS300_SRCS += SRS300_registerRecordDeviceDriver.cpp

# Build the main IOC entry point on workstation OSs.
SRS300_SRCS_DEFAULT += SRS300Main.cpp
SRS300_SRCS_vxWorks += -nil-

# Add support from base/src/vxWorks if needed
#SRS300_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

# Finally link to the EPICS Base libraries
SRS300_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

