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

ping_ip = ("192.168.255.2","192.168.255.3")
vpdn_ip = ("10.113.29.160","10.5.26.245")
site_name = ("CD","SZ")
for i in range (2):
    ping_result = Connect.send_command("ping " + ping_ip[i] + " repeat 10")
    ping_count = len(re.findall("!",ping_result))
    if ping_count < 9:
        Connect.send_command("clear vpdn tunnel pptp ip remote " + vpdn_ip[i])
        logtofile(ping_result,site_name[i] + " Site","disconnected")
    else:
        logtofile(ping_result,site_name[i] + " Site","connected")

Connect.disconnect()
