#!/bin/bash
#need "tee" installed

#The material and information contained in this script is for general information purposes only.
#You should not rely upon the material or information on this script as a basis for making any business, legal, or any other decisions.
#This script makes no representations or warranties of any kind, express or implied about the completeness, accuracy, reliability, suitability, information,  or source code.
#Any reliance you place on such material is therefore strictly at your own risk.

#============================================================================================================================
#HOW TO USE
#First, the OCI cli must be installed as the user executing the script, refer to the link below
#https://eclipsys.ca/install-oci-cli-in-5-minutes/

#Need tee installed
#sudo yum install tee

#Notifications must be setup in OCI, with a topic that has associated emails, refer to the link below
#https://docs.oracle.com/en-us/iaas/Content/Notification/Concepts/notificationoverview.htm

#Crontan knowledge, you will specify how often to run the script, refer to this site to tinker with times
#https://crontab.guru/

#The variables below must be edited, and correct -- or the script will not work. Verify the OCID of the topic very carefully
#============================================================================================================================


#============================================================================================================================

#============================================================================================================================
#EDIT THE FOLLOWING VARIABLES

userBashrc=/home/opc/.bashrc #where variables are sourced usually .bashrc for oci db/compute
tempSpool=/tmp/tmpSpool.txt #make sure have read/write on directory
sshKey=/ssh/key/file.pem #ssh key location for the ssh command, make sure the public key is in the DBCS oracle users authorized_keys and also the permission is set to chmod 600
thisServersIP=xx.xx.xx.xx #ip of server running for notifications
serverName=ords #server name for email, cosmetic and can be anything
ociTopicID=ocid1.onstopic.oc1.iad.xxxxxxxxxxxxx #Replace with the topic OCID, starts with cid1.onstopic.oc1.......etc
serverRole=Prod #Prod, Dev, etc -- this is used in the email title for notifications
# DATABASE MUST USE SYS USER - Script only does selects
databaseIP=xx.xx.xx.xxx #server IP of DB
databaseTnsAlias=xxxxx #Replace with the ALIAS in the TNSNAMES.ORA
databaseServiceName=ords.sub03222016131.xxxxxxxx.xxx.xxx #exact service name from listener.ora
databaseUserPass=xxxxxxxx #Plain-text password for the user, which is why sys shouldn't be used and only connect grant for the user is given.
databaseSID=xxxx # echo $ORACLE_SID and replace
databasePDBtoCheck=xxxx #what PDB to check if read and write mode
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#NO MANUAL CHANGES ARE NEEDED BELOW THIS LINE, SCRIPT WILL BE BROKEN
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


emailBodyInfo="The following are variables used in the script \r\n SERVER NAME= ${serverName} \r\n  SERVER IP= ${databaseIP} \r\n ROLE OF SERVER= ${serverRole} DB SID= ${databaseSID} \r\n PDB= ${databasePDBtoCheck} \r\n" #Puts all the specified variables into a formatted JSON list for email notification
emailBodyInfoServerFail="The following are variables used in the script \r\n IP OF SERVER USED FOR CHECKS= ${databaseIP} \r\n  DATABASE IP= ${serverIP} \r\n ROLE OF DB= ${serverRole} \r\n DB SID= ${databaseSID} \r\n PDB= ${databasePDBtoCheck} \r\n" #Puts all the specified variables into a formatted JSON list for email notification
newLineQuickAdd="====================================================" #Quick way to insert readable newline in email body

# Source bashrc file for crontab
source ${userBashrc}

#Setting variables to make final command easier to read
tnsPing="tnsping ${databaseTnsAlias}"
pmonCheck="ps -ef | grep pmon"
sqlCommand='{ echo "set linesize 200"; echo "set pages 10"; echo "set heading on"; echo "show pdbs"; echo "exit;";} >> /tmp/ASQLTEST.sql; chmod 777 /tmp/ASQLTEST.sql; sqlplus -s -l sys/'${databaseUserPass}'@'${databaseTnsAlias}' as sysdba @/tmp/ASQLTEST.sql ; rm /tmp/ASQLTEST.sql'

#sqlCommand=sqlplus sys/${databaseUserPass}@${databaseTnsAlias} as sysdba @sqlCheckScript.sql #This is if running remote script, not recommended due to possibility of editing remote script
#Final SSH command, it spools to a file will be used for error checking
ssh -i ${sshKey} oracle@${databaseIP} "${tnsPing}; ${pmonCheck}; ${sqlCommand}; exit" > ${tempSpool}
#cat ${tempSpool}
# Checking if file exists
if [ -f ${tempSpool} ]; then
# Grepping the output of file to see if ora_pmon_oraclesid is present
catPrep=$(cat "${tempSpool}" | grep -E "ora_pmon_${databaseSID}")
if [[ ${catPrep} == *"${databaseSID}"* ]]; then echo "'${databaseSID}' was found in PMON"; else oci ons message publish --message-type JSON --title "PMON for ${serverRole} database ${databaseSID} on server ${serverName} ${databaseIP} not found" --body '{"DEFAULT": "PMON was unable to be grepped with ps on server '"${serverName}"' \r\nPMON was looking for '"${databaseSID}"' \r\n '"${emailBodyInfo}"' \r\n '"${newLineQuickAdd}"' "}' --topic-id ${ociTopicID}; fi

# RUNNING GREPS TO FIND IF TNSPING WORKED, AND IF TNSPING RESOLVED TNS-ERROR
tnsPingCatPrep=$(cat "${tempSpool}" | grep -P -i  ".*${databaseServiceName}.*")
tnsErrorCheck=$(cat "${tempSpool}" |  grep -P -i  ".*TNS-.....:.*")
#if [ "${tnsPingCatPrep}" != "" ]; then echo "ALL GOOD"; else if [ "{tnsErrorCheck}" != "" ]; then echo "TNS ERROR FOUND" && echo "${tnsErrorCheck}"; else echo "General ERROR, no TNS CODE"; fi; fi
if [ "${tnsPingCatPrep}" != "" ]; then echo "TNSPING ALL GOOD"; else oci ons message publish --message-type JSON --title "${serverRole} database ${databaseSID} on server ${serverName} ${databaseIP} was unable to be tnspinged" --body '{"DEFAULT": "TNS PING of server '"${serverName}"' has failed \r\nThe TNS Alias  used was '"${databaseTnsAlias}"' \r\n '"${emailBodyInfo}"' \r\n '"${newLineQuickAdd}"' "}' --topic-id ${ociTopicID}; fi

# RUNNING GREPS TO FIND IF PDB IS IN OPEN READ WRITE
pdbReadWriteCheck=$(cat "${tempSpool}" | grep -P -i  ".*${databasePDBtoCheck}.*READ WRITE NO.*")
if [ "${pdbReadWriteCheck}" != "" ]; then echo "PDB '${databasePDBtoCheck}' is in read write"; else oci ons message publish --message-type JSON --title "${serverRole} database ${databaseSID} ${databaseIP} PDB ${databasePDBtoCheck} is not in read write mode" --body '{"DEFAULT": "PDB Check of server '"${serverName}"' has failed \r\nThe PDB target was ${databasePDBtoCheck} \r\n '"${emailBodyInfo}"' \r\n '"${newLineQuickAdd}"' "}' --topic-id ${ociTopicID}; fi

#Final lines to remove the file
chmod 777 ${tempSpool}
rm ${tempSpool}
# else hit if file doesn't exist
else
oci ons message publish --message-type JSON --title "Script checking server ${thisServersIP} was unable to create a file for ${serverRole} database ${databaseSID} ${databaseIP}" --body '{"DEFAULT": "The server checking the database was unable to generate a file to store variables \r\n '"${emailBodyInfoServerFail}"' \r\n '"${newLineQuickAdd}"' "}' --topic-id ${ociTopicID}
#end of main loop checking if FILE IS FOUND
fi
