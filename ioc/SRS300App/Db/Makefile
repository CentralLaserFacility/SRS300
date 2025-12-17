TOP=../..
include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE


#----------------------------------------------------
# Create and install (or just install) into <top>/db
# databases, templates, substitutions like this
DB += devSRS_PS300_common.db

DB += devSRS_PS3xx.substitutions

DB += devSRS_PS3xx.template

DB_INSTALLS += $(ASYN)/db/asynRecord.db

#----------------------------------------------------
# If <anyname>.db template is not named <anyname>*.template add
# <anyname>_template = <templatename>
DATA += ps300.proto

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

