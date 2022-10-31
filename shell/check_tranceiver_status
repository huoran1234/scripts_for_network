#!/bin/bash

IFS=$'\n'
rx_high_10g='1'
rx_low_10g='-13.1'
tx_high_10g='0'
tx_low_10g='-10.3'

rx_high_25g='4.4'
rx_low_25g='-12.3'
tx_high_25g='4.4'
tx_low_25g='-10.4'

rx_high_100g='5.5'
rx_low_100g='-8.7'
tx_high_100g='6'
tx_low_100g='-7'

rm -rf result.txt
touch result.txt

device_all=$(ls config | sort | awk -F "\t" '{print $1}' $2 | sort | uniq)
for device in ${device_all[@]}
do
    echo "==========Start of $device==========" >> result.txt
    for line in $(cat "config/"$device | grep "transceiver diagnostic information:")
    do
        if [[ $(echo $line | grep Ten-GigabitEthernet) != "" ]]
        then
            echo $line
            line="$(echo "${line}" | sed 's/\//\\\//g')"
            result=$(sed -n "/${line}/,+3p" "config/"$device)
            result_rx=$(echo $result | awk '{print $19}')
            result_tx=$(echo $result | awk '{print $20}')
            echo $result
            if [[ $(echo $result | grep -a "The transceiver is absent.") != "" ]]
            then
                echo 'No SFP found.'
            elif [[ $(echo $result | grep -a "The transceiver does not support this function") != "" ]]
            then
                if [[ `echo $line | grep "Ten-GigabitEthernet1\/0\/27"` != "" || `echo $line | grep "Ten-GigabitEthernet1\/0\/44"` != "" || `echo $line | grep "Ten-GigabitEthernet1\/0\/45"` != "" || `echo $line | grep "Ten-GigabitEthernet1\/0\/46"` != ""  || `echo $line | grep "Ten-GigabitEthernet1\/0\/47"` != "" ]]
                then
                    echo $line >> result.txt
                    echo '10G SFP not supported.' >> result.txt
                fi
            elif [[ $result_rx == '-36.96' && $result_tx == '-36.96' ]]
            then
                echo 'Already shutdown.'
            elif [[ $result_rx == '-36.96' ]]
            then
                echo $line >> result.txt
                echo 'No Cable ,no device connects or need to shutdown.' >> result.txt
            elif [[ $result_tx == '-36.96' ]]
            then
                echo $line >> result.txt
                echo 'Attention!!! Please login to device to check the status.' >> result.txt
            elif [[ $(echo "$result_rx > $rx_high_10g" | bc) -eq 1 || $(echo "$result_rx < $rx_low_10g" | bc) -eq 1 ]]
            then
                echo $line >> result.txt
                echo 'Oh shit,rx error,faulty SFP or cable.' >> result.txt
            elif [[ $(echo "$result_tx > $tx_high_10g" | bc) -eq 1 || $(echo "$result_tx < $tx_low_10g" | bc) -eq 1 ]]
            then
                echo $line >> result.txt
                echo 'Oh shit,tx error,faulty SFP.' >> result.txt
            else 
                echo 'Nice man!'
            fi
        elif [[ $(echo $line | grep Twenty-FiveGigE) != "" ]]
        then
            echo $line
            line="$(echo "${line}" | sed 's/\//\\\//g')"
            result=$(sed -n "/${line}/,+3p" "config/"$device)
            result_rx=$(echo $result | awk '{print $19}')
            result_tx=$(echo $result | awk '{print $20}')
            echo $result
            if [[ $(echo $result | grep -a "The transceiver is absent.") != "" ]]
            then
                echo 'No SFP found.'
            elif [[ $(echo $result | grep -a "The transceiver does not support this function") != "" ]]
            then
                echo $line >> result.txt
                echo '25G SFP not supported.' >> result.txt
            elif [[ $result_rx == '-36.96' && $result_tx == '-36.96' ]]
            then
                echo 'Already shutdown.'
            elif [[ $result_rx == '-36.96' ]]
            then
                echo $line >> result.txt
                echo 'No Cable ,no device connects or need to shutdown.' >> result.txt
            elif [[ $result_tx == '-36.96' ]]
            then
                echo $line >> result.txt
                echo 'Attention!!!Please login to device to check the status.' >> result.txt
            elif [[ $(echo "$result_rx > $rx_high_25g" | bc) -eq 1 || $(echo "$result_rx < $rx_low_25g" | bc) -eq 1 ]]
            then
                echo $line >> result.txt
                echo 'Oh shit,rx error,faulty SFP or cable.' >> result.txt
            elif [[ $(echo "$result_tx > $tx_high_25g" | bc) -eq 1 || $(echo "$result_tx < $tx_low_25g" | bc) -eq 1 ]]
            then
                echo $line >> result.txt
                echo 'Oh shit,tx error,faulty SFP.' >> result.txt
            else 
                echo 'Nice man!'
            fi
        elif [[ $(echo $line | grep HundredGigE) != "" ]]
        then
            echo $line
            line="$(echo "${line}" | sed 's/\//\\\//g')"
            result=$(sed -n "/${line}/,+8p" "config/"$device)
            result_rx1=$(echo $result | awk '{print $24}')
            result_rx2=$(echo $result | awk '{print $29}')
            result_rx3=$(echo $result | awk '{print $34}')
            result_rx4=$(echo $result | awk '{print $39}')
            result_tx1=$(echo $result | awk '{print $25}')
            result_tx2=$(echo $result | awk '{print $30}')
            result_tx3=$(echo $result | awk '{print $35}')
            result_tx4=$(echo $result | awk '{print $40}')
            if [[ $(echo $result | grep -a "The transceiver is absent.") != "" ]]
            then
                echo 'No SFP found.'
            elif [[ `echo $result | grep -a "The transceiver does not support this function"` != "" ]]
            then
                echo $line >> result.txt
                echo '100G SFP not supported.' >> result.txt
            elif [[ $result_rx1 == '-36.96' && $result_rx2 == '-36.96' && $result_rx3 == '-36.96' && $result_rx4 == '-36.96'  && $result_tx1 == '-36.96'  && $result_tx2 == '-36.96'  && $result_tx3 == '-36.96'  && $result_tx4 == '-36.96' ]]
            then
                echo 'Already shutdown.'
            elif [[ $result_rx1 == '-36.96' && $result_rx2 == '-36.96' && $result_rx3 == '-36.96' && $result_rx4 == '-36.96' ]]
            then
                echo $line >> result.txt
                echo 'No Cable ,no device connects or need to shutdown.' >> result.txt
            elif [[ $result_tx1 == '-36.96' && $result_tx2 == '-36.96' && $result_tx3 == '-36.96' && $result_tx4 == '-36.96' ]]
            then
                echo $line >> result.txt
                echo 'Attention!!!Please login to device to check the status.' >> result.txt
            elif [[ `echo "$result_rx1 > $rx_high_100g" | bc` -eq 1 || `echo "$result_rx1 < $rx_low_100g" | bc` -eq 1 || `echo "$result_rx2 > $rx_high_100g" | bc` -eq 1 || `echo "$result_rx2 < $rx_low_100g" | bc` -eq 1 || `echo "$result_rx3 > $rx_high_100g" | bc` -eq 1 || `echo "$result_rx3 < $rx_low_100g" | bc` -eq 1 || `echo "$result_rx4 > $rx_high_100g" | bc` -eq 1 || `echo "$result_rx4 < $rx_low_100g" | bc` -eq 1 ]]
            then
                echo $line >> result.txt
                echo 'Oh shit,rx error,faulty SFP or cable.' >> result.txt
            elif [[ `echo "$result_tx1 > $tx_high_100g" | bc` -eq 1 || `echo "$result_tx1 < $tx_low_100g" | bc` -eq 1 || `echo "$result_tx2 > $tx_high_100g" | bc` -eq 1 || `echo "$result_tx2 < $tx_low_100g" | bc` -eq 1 || `echo "$result_tx3 > $tx_high_100g" | bc` -eq 1 || `echo "$result_tx3 < $tx_low_100g" | bc` -eq 1 || `echo "$result_tx4 > $tx_high_100g" | bc` -eq 1 || `echo "$result_tx4 < $tx_low_100g" | bc` -eq 1 ]]
            then
                echo $line >> result.txt
                echo 'Oh shit,tx error,faulty SFP.' >> result.txt
            else 
                echo 'Nice man!'
            fi
        fi
    done
echo -e "==========End of $device==========\n\n\n\n" >> result.txt
done
