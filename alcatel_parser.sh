#!/bin/bash

#:Date Created  : 2012-03-20
#:Last Edit     : 2012-03-21
#:Author        : Yordan Radunchev
#:Version       : 0.2

# Alcatel OmniPCX Enterprise
# Accounting tickets processing

# VAR   - Alcatel PBX ticket field
# --------------------------------
# CTYP  - CallType,167,168,R
# CDIA  - CalledNumber,6,35,L
# CDAT  - EndDateTime,170,186,N
# CDUR  - CallDuration,202,211,R
# CCHR  - ChargedNumber,36,65,L
# --------------------------------
# Exit status:
# 51 - working directory does not exists


# Working Directory
WRKD=${HOME}/Projects/pbx/w
# Working file
WRKF=${WRKD}/work
# Outgoing calls report
WRKO=${WRKD}/ocalls.csv
# Incoming calls report
WRKI=${WRKD}/icalls.csv

[ -d ${WRKD} ] || exit 51

# Call type definition - may be different for your PBX.
OCLS=" 0" # Outgoing calls
ICLS=" 4" # Incoming calls

cd ${WRKD}

# Clear any old files
[ -f ${WRKF} ] && rm ${WRKF}
[ -f ${WRKO} ] && rm ${WRKO}
[ -f ${WRKI} ] && rm ${WRKI}
touch ${WRKF}

# Process tikets in wroking directory
for FILD in ${WRKD}/*.DAT; do zcat ${FILD} | awk 'NR>1{print $0}' >> ${WRKF}; done

# Parse call data in csv format
while read LINE; do
    # extention number:
    CCHR=${LINE:35:30}
    CCHR="${CCHR%"${CCHR##*[![:space:]]}"}"
    # called number:
    CDIA=${LINE:5:30}
    CDIA="${CDIA%"${CDIA##*[![:space:]]}"}"
    # date and time:
    CDAT=${LINE:169:17}
    # YYYYMMDD -> YYYY-MM-DD
    DATE=${CDAT:0:4}"-"${CDAT:4:2}"-"${CDAT:6:2}
    TIME=${CDAT:9}
    # call CDUR:
    CDUR=${LINE:201:10}
    CDUR="${CDUR#"${CDUR%%[![:space:]]*}"}"
    # call direction:
    CTYP=${LINE:166:2}
    # send data to the corresponding file
    case ${CTYP} in
    ${OCLS}) echo "${CDIA};${DATE};${TIME};${CDUR};;;${CCHR}" >> ${WRKO}
    ;;
    ${ICLS}) echo "${CDIA};${DATE};${TIME};${CDUR};;;${CCHR}" >> ${WRKI}
    ;;
    esac
done < ${WRKF}