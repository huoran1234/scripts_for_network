#!/usr/bin/python3
from netmiko import ConnectHandler
import re
import time

def logtofile(arg1,location,status):
        logtime = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
        value = "--------------------\n" + logtime + " " + location + " " + status + arg1 + "\n--------------------\n"
        f=open("/var/log/monitor_vpn_log.txt","a")
        f.write(value)
        f.close()
        return

BJ_C2811 = {"host": "192.168.63.6",
            "username": "admin",
            "password": "isgtssL2!",
            "device_type": "cisco_ios",
}

Connect = ConnectHandler(**BJ_C2811)
Connect.enable()

ping_cd = "ping 192.168.255.2 repeat 10"
ping_sz = "ping 192.168.255.3 repeat 10"
ping_cd_result = Connect.send_command(ping_cd)
ping_sz_result = Connect.send_command(ping_sz)
ping_cd_filter = re.findall('!',ping_cd_result)
ping_sz_filter = re.findall('!',ping_sz_result)
ping_cd_counter = len(ping_cd_filter)
ping_sz_counter = len(ping_sz_filter)

if ping_cd_counter < 9:
        Connect.send_command("clear vpdn tunnel pptp ip remote 10.113.29.160")
        logtofile(ping_cd_result,"CD Site","disconnected")
else:
        logtofile(ping_cd_result,"CD Site","connected")

if ping_sz_counter < 9:
        Connect.send_command("clear vpdn tunnel pptp ip remote 10.5.26.245")
        logtofile(ping_sz_result,"SZ Site","disconnected") 
else:
        logtofile(ping_sz_result,"SZ Site","connected")

Connect.disconnect()

#For Debugging
#print(ping_cd_result)
#print(ping_cd_filter)
#print(ping_cd_counter)
#print(ping_sz_result)
#print(ping_sz_filter)
#print(ping_sz_counter)

#Sample for netmiko
#Connect.enable()
#To_Issue = "show ip interface brief"
#print(Connect.send_command(To_Issue))
#clear_vpdn_command = "clear vpdn tunnel pptp all"
#output = Connect.send_command(clear_vpdn_command, expect_string="[confirm]")
