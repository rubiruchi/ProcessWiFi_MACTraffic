#!/bin/bash
#$csv_path$separator$csv $out_path $clientFile $ssidFile
#fileName=$1
#output_file=$2
#mac_file=$2
#pcap_file="converted.csv"

pcap_file=$1
output_folder=$2
output_file="/CausalAnalysis-DFA.csv"
AP=$3
AP_SSID=$4
tempSA="/tmp/SAToProcess.csv"

<<Comment
1 frame.time_epoch 
2 frame.number 
3 frame.len 
4 radiotap.channel.freq 
5 radiotap.mactime 
6 radiotap.datarate 
7 wlan.fc.type_subtype 
8 wlan_mgt.ssid 
9 wlan.bssid 
10 wlan_mgt.ds.current_channel 
11 wlan_mgt.qbss.scount 
12 wlan.fc.retry 
13 wlan.fc.pwrmgt 
14 wlan.fc.moredata 
15 wlan.fc.frag 
16 wlan.duration 
17 wlan.ra 
18 wlan.ta 
19 wlan.sa 
20 wlan.da 
21 wlan.seq 
22 wlan.qos.priority 
23 wlan.qos.amsdupresent 
24 wlan.fc.type 
25 wlan_mgt.fixed.reason_code 
26 wlan_mgt.fixed.status_code 
27 wlan.fc.ds 
28 radiotap.dbm_antsignal
Comment
####
home_dir=`eval echo ~$USER/`
codePath=$home_dir"Scripts/CausalAnalysis/CausalAnalysis-DFA/"
#assoc success status_code 0x0000
#deauth reason_code 0x000f
i=1


#echo "Filtering Beacons"
#`awk -F"," -v AP=$AP 'BEGIN{OFS=",";} {if ($7=="0x08" && $19 == AP) print $1}' $pcap_file > /tmp/beacons_arrival.csv`
if [ -f $output_folder"/"$output_file ]; then
	rm $output_folder"/"$output_file
fi 
echo "....Searching for Source Addresses with more than 10 Probe Requests"
`cat $pcap_file |  awk -F, -v ft1="0x04" -v ft2="4" '{ if ( $7 == ft1 || $7 == ft2) print $7, $19}' | sort | uniq -c | awk -F' ' -v  OFS="," '{ if ($1 > 10) print $3}' > $tempSA`

echo "....Source Addresses with more than 10 Probe Requests found - /tmp/SAToProcess.csv"

totalMAC=`cat $tempSA|wc -l`

if [ -f $output_folder"/"$output_file ]; then
	rm $output_folder"/"$output_file
fi
touch $output_folder"/"$output_file

#while [ $i -le $totalMAC ]; do

#SA=`head -n $i $tempSA|tail -1`
SA="44:6d:57:31:40:6f"

echo "Processing MAC[$i/$totalMAC]: $SA"
echo

echo "Filtering Client Frames"		
`awk -F"," -v SA=$SA -v AP=$AP 'BEGIN{OFS=",";} {if ($19 == SA || $18 == SA || $17 == SA || ($19 == AP && ($7 == "0x08" || $7 == "8"))) print $1,$7,$8,$9,$13,$17,$18,$19,$20,$25,$26,$27,$28,$12}' $pcap_file > /tmp/fileToProcess.csv`
echo "Filtering over - /tmp/fileToProcess.csv"	

count_preq=`cat /tmp/fileToProcess.csv| awk -F, -v ft1="4" -v ft2="0x04" '{ if ( $2 == ft1 || $2 == ft2) print }' | wc -l`
if [ $count_preq -gt 0 ]; then
	
	echo "Preprocessing For DFA Started for $SA"
	#echo "Filtering Beacon Frames"
	#`awk -F"," 'BEGIN{OFS=",";} {if ($7=="0x08") print $8,$9}' $pcap_file > /tmp/beacons.csv`

	#output_file=$output_file"-"$SA".csv"

	`$codePath/PreProcessData.sh /tmp/fileToProcess.csv $AP $SA $AP_SSID >> $output_folder"/"$output_file`
	echo "Preprocessing For DFA Ended for $SA"
else
 echo "No Probe Requests found for $SA"
fi
i=`expr $i + 1`
#done


