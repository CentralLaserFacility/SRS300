TOP=../..
include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE


#----------------------------------------------------
# Create and install (or just install) into <top>/db
# databases, templates, substitutions like this
DB += devSRS_PS300_common.db
#DB += devSRS_PS310_neg.db
#DB += devSRS_PS310_pos.db
#DB += devSRS_PS325_neg.db
#DB += devSRS_PS325_pos.db
#DB += devSRS_PS350_neg.db
#DB += devSRS_PS350_pos.db
#DB += devSRS_PS355.db
#DB += devSRS_PS365.db
#DB += devSRS_PS370.db
#DB += devSRS_PS375.db

#DB += devSRS_PS310_pos.substitutions
#DB += devSRS_PS325_pos.substitutions
#DB += devSRS_PS350_pos.substitutions
#DB += devSRS_PS310_neg.substitutions
#DB += devSRS_PS325_neg.substitutions
#DB += devSRS_PS350_neg.substitutions
#DB += devSRS_PS355.substitutions
#DB += devSRS_PS365.substitutions
#DB += devSRS_PS370.substitutions
DB += devSRS_PS375.substitutions

DB += devSRS_PS3xx.template

DB_INSTALLS += $(ASYN)/db/asynRecord.db

#----------------------------------------------------
# If <anyname>.db template is not named <anyname>*.template add
# <anyname>_template = <templatename>
DATA += ps300.proto

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

