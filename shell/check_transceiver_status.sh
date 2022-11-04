#!/bin/bash

timestamp=$(date +%Y-%m%d-%H%M)
#定义读取行时换行作为分隔符
IFS=$'\n'

#定义10G，25G和100G的rx和tx光衰阈值
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

#定义40个线程
thread=40
fifotemp="/tmp/$$.fifo"
mkfifo $fifotemp
exec 4<>$fifotemp
rm -rf $fifotemp
for ((i=1;i<=$thread;i++));do
    echo >&4
done

#删除上次运行生成的结果文件
rm -rf result/*.*

#输出config目录下的所有抓取信息，保存为列表供文件读取
device_all=$(ls config | sort | awk -F "\t" '{print $1}' $2 | sort | uniq)

#按序读取文件，开始进行分细
for device in ${device_all[@]}
do
{
    read -u4
    echo "==========Start of $device==========" >> "result/"$device".txt"
    #文件逐行读取，通过过滤关键字减少全量读写，提高效率，提取含接口号的相关行为后续读取光功率
    for line in $(cat "config/"$device | grep "transceiver diagnostic information:")
    do
        #当接口为10G时，使用10G的光功率判断逻辑进行分析
        if [[ $(echo $line | grep Ten-GigabitEthernet) != "" ]]
        then
            echo $line
            line_without_slash="$(echo "${line}" | sed 's/\//\\\//g')"
            #读取下面三行用于提取rxtx光功率
            result=$(sed -n "/${line_without_slash}/,+3p" "config/"$device)
            #读取下面一行用于排除不支持读取和没有的SFP（避免误判）
            result_1st_line=$(sed -n "/${line_without_slash}/,+1p" "config/"$device)
            #读取rx光功率
            result_rx=$(echo $result | awk '{print $19}')
            #读取tx光功率
            result_tx=$(echo $result | awk '{print $20}')
            echo $result
            #判断是否没有使用SFP
            if [[ $(echo $result_1st_line | grep -a "The transceiver is absent.") != "" ]]
            then
                echo 'No SFP found.'
            #判断是否SFP不支持读取光功率参数
            elif [[ $(echo $result_1st_line | grep -a "The transceiver does not support this function") != "" ]]
            then
                #排除27，44，45，46，47口（目前连接的1G-BaseT，确认不支持读取信息）
                if [[ `echo $line | grep "Ten-GigabitEthernet1\/0\/27"` != "" || `echo $line | grep "Ten-GigabitEthernet1\/0\/44"` != "" || `echo $line | grep "Ten-GigabitEthernet1\/0\/45"` != "" || `echo $line | grep "Ten-GigabitEthernet1\/0\/46"` != ""  || `echo $line | grep "Ten-GigabitEthernet1\/0\/47"` != "" ]]
                then
                    echo $line >> "result/"$device".txt"
                    echo '10G Port SFP not supported.' >> "result/"$device".txt"
                fi
            #判断rx和tx都没有光，可能为端口shutdown或对端没有没有发光
            elif [[ $result_rx == '-36.96' && $result_tx == '-36.96' ]]
            then
                echo 'No rx and no tx. Already shutdown and no light from peer.'
            #判断rx无光或tx无光，可能为对端设备没有发光或本端接口shutdown
            elif [[ $result_rx == '-36.96' && $result_tx != '-36.96' ]]
            then
                echo 'No rx only. No Cable, no device connected or need to shutdown.'
            #
            elif [[ $result_rx != '-36.96' && $result_tx == '-36.96' ]]
            then
                echo $line >> "result/"$device".txt"
                echo 'No tx only. Port already shutdown.' >> "result/"$device".txt"
            #判断rx是否在正常范围内
            elif [[ $(echo "$result_rx > $rx_high_10g" | bc) -eq 1 || $(echo "$result_rx < $rx_low_10g" | bc) -eq 1 ]]
            then
                echo $line >> "result/"$device".txt"
                echo 'Rx error, faulty SFP or cable.' >> "result/"$device".txt"
            #判断tx是否在正常范围内    
            elif [[ $(echo "$result_tx > $tx_high_10g" | bc) -eq 1 || $(echo "$result_tx < $tx_low_10g" | bc) -eq 1 ]]
            then
                echo $line >> "result/"$device".txt"
                echo 'Tx error, faulty SFP.' >> "result/"$device".txt"
            #都符合条件为正常
            else 
                echo 'Good SFP!'
            fi
        #当接口为10G时，使用10G的光功率判断逻辑进行分析
        elif [[ $(echo $line | grep Twenty-FiveGigE) != "" ]]
        then
            echo $line
            line_without_slash="$(echo "${line}" | sed 's/\//\\\//g')"
            result=$(sed -n "/${line_without_slash}/,+3p" "config/"$device)
            result_1st_line=$(sed -n "/${line_without_slash}/,+1p" "config/"$device)
            result_rx=$(echo $result | awk '{print $19}')
            result_tx=$(echo $result | awk '{print $20}')
            echo $result
            if [[ $(echo $result_1st_line | grep -a "The transceiver is absent.") != "" ]]
            then
                echo 'No SFP found.'
            elif [[ $(echo $result_1st_line | grep -a "The transceiver does not support this function") != "" ]]
            then
                if [[ `echo $line | grep "Ten-GigabitEthernet1\/0\/44"` != "" || `echo $line | grep "Ten-GigabitEthernet1\/0\/45"` != "" || `echo $line | grep "Ten-GigabitEthernet1\/0\/46"` != ""  || `echo $line | grep "Ten-GigabitEthernet1\/0\/47"` != "" ]]
                then
                    echo $line >> "result/"$device".txt"
                    echo '25G Port SFP not supported.' >> "result/"$device".txt"
                fi
            elif [[ $result_rx == '-36.96' && $result_tx == '-36.96' ]]
            then
                echo $line
                echo 'No rx and no tx. Already shutdown and no light from peer.'
            elif [[ $result_rx == '-36.96' && $result_tx != '-36.96' ]]
            then
                echo $line
                echo 'No rx only. No Cable, no device connected or already shutdown.'
            elif [[ $result_rx != '-36.96' && $result_tx == '-36.96' ]]
            then
                echo $line >> "result/"$device".txt"
                echo 'No tx only. Port already shutdown.' >> "result/"$device".txt"
            elif [[ $(echo "$result_rx > $rx_high_25g" | bc) -eq 1 || $(echo "$result_rx < $rx_low_25g" | bc) -eq 1 ]]
            then
                echo $line >> "result/"$device".txt"
                echo 'Rx error, faulty SFP or cable.' >> "result/"$device".txt"
            elif [[ $(echo "$result_tx > $tx_high_25g" | bc) -eq 1 || $(echo "$result_tx < $tx_low_25g" | bc) -eq 1 ]]
            then
                echo $line >> "result/"$device".txt"
                echo 'Tx error, faulty SFP.' >> "result/"$device".txt"
            else 
                echo 'Good SFP!'
            fi
        #当接口为100G时，使用100G的光功率判断逻辑进行分析
        elif [[ $(echo $line | grep HundredGigE) != "" ]]
        then
            echo $line
            line_without_slash="$(echo "${line}" | sed 's/\//\\\//g')"
            result=$(sed -n "/${line_without_slash}/,+8p" "config/"$device)
            result_1st_line=$(sed -n "/${line_without_slash}/,+1p" "config/"$device)
            result_rx1=$(echo $result | awk '{print $24}')
            result_rx2=$(echo $result | awk '{print $29}')
            result_rx3=$(echo $result | awk '{print $34}')
            result_rx4=$(echo $result | awk '{print $39}')
            result_tx1=$(echo $result | awk '{print $25}')
            result_tx2=$(echo $result | awk '{print $30}')
            result_tx3=$(echo $result | awk '{print $35}')
            result_tx4=$(echo $result | awk '{print $40}')
            if [[ $(echo $result_1st_line | grep -a "The transceiver is absent.") != "" ]]
            then
                echo 'No SFP found.'
            elif [[ `echo $result_1st_line | grep -a "The transceiver does not support this function"` != "" ]]
            then
                echo $line >> "result/"$device".txt"
                echo '100G Port SFP not supported.' >> "result/"$device".txt"
            elif [[ $result_rx1 == '-36.96' && $result_rx2 == '-36.96' && $result_rx3 == '-36.96' && $result_rx4 == '-36.96'  && $result_tx1 == '-36.96'  && $result_tx2 == '-36.96'  && $result_tx3 == '-36.96'  && $result_tx4 == '-36.96' ]]
            then
                echo 'No rx and no tx. Already shutdown and no light from peer.'
            elif [[ $result_rx1 == '-36.96' || $result_rx2 == '-36.96' || $result_rx3 == '-36.96' || $result_rx4 == '-36.96' ]]
            then
                echo 'No rx. No Cable, no device connected or need to shutdown.'
            elif [[ $result_tx1 == '-36.96' || $result_tx2 == '-36.96' || $result_tx3 == '-36.96' || $result_tx4 == '-36.96' ]]
            then
                echo $line >> "result/"$device".txt"
                echo 'No tx. Port already shutdown.' >> "result/"$device".txt"
            elif [[ `echo "$result_rx1 > $rx_high_100g" | bc` -eq 1 || `echo "$result_rx1 < $rx_low_100g" | bc` -eq 1 || `echo "$result_rx2 > $rx_high_100g" | bc` -eq 1 || `echo "$result_rx2 < $rx_low_100g" | bc` -eq 1 || `echo "$result_rx3 > $rx_high_100g" | bc` -eq 1 || `echo "$result_rx3 < $rx_low_100g" | bc` -eq 1 || `echo "$result_rx4 > $rx_high_100g" | bc` -eq 1 || `echo "$result_rx4 < $rx_low_100g" | bc` -eq 1 ]]
            then
                echo $line >> "result/"$device".txt"
                echo 'Rx error, faulty SFP or cable.' >> "result/"$device".txt"
            elif [[ `echo "$result_tx1 > $tx_high_100g" | bc` -eq 1 || `echo "$result_tx1 < $tx_low_100g" | bc` -eq 1 || `echo "$result_tx2 > $tx_high_100g" | bc` -eq 1 || `echo "$result_tx2 < $tx_low_100g" | bc` -eq 1 || `echo "$result_tx3 > $tx_high_100g" | bc` -eq 1 || `echo "$result_tx3 < $tx_low_100g" | bc` -eq 1 || `echo "$result_tx4 > $tx_high_100g" | bc` -eq 1 || `echo "$result_tx4 < $tx_low_100g" | bc` -eq 1 ]]
            then
                echo $line >> "result/"$device".txt"
                echo 'Tx error, faulty SFP.' >> "result/"$device".txt"
            else 
                echo 'Good SFP!'
            fi
        fi
    done
    echo -e "==========End of $device==========\n\n\n\n" >> "result/"$device".txt"
    echo >&4
} &
done
wait
exec 4>&-
#将result目录下的单独文件合并成一份结果
cat "result"/* >> "result_"$timestamp".txt"
exit 0
