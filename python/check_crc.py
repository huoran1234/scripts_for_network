#!/usr/bin/python3
from netmiko import ConnectHandler
from netmiko import NetMikoAuthenticationException
from netmiko import NetMikoTimeoutException
from multiprocessing import Pool
import re,time,os

def Check_CRC():
    #Open the IP list file
    line = open(os.path.abspath('check_crc.txt'), 'r').readlines()
    for i in range(len(line)):
        try:
            sw = {"host": line[i],
                "username": "username",
                "password": "password",
                "device_type": "hp_comware",
            }
            conn = ConnectHandler(**sw)
            conn.enable()
            cmd = "display counters inbound interface"
            output = conn.send_command(cmd)
            conn.disconnect()
            #Split the output to sigle line and remove unusable data
            output_line = output.split("\n")
            del output_line[-3:-1]
            del output_line[0]
            output_line.pop()
            #Splie every line to single string and select the last data
            for x in range(len(output_line)):
                output_last = int(output_line[x].split(" ")[-1])
                output_first = output_line[x].split(" ")[0]
                if output_last > 0:
                    print(line[i] + '\n' + output_first + '\n' + 'Err (pkts) = ' + output_last)
                    print(x)

        except (EOFError,NetMikoTimeoutException):
            print('Can not connect to Device ' + line[i])
        except (EOFError, NetMikoAuthenticationException):
            print('username/password wrong!' + line[i])
        except (ValueError, NetMikoAuthenticationException):
            print('enable password wrong!' + line[i])
        finally:
            continue

if __name__=="__main__":
    po = Pool(3)  # 定义一个进程池，最大进程数3
    for i in range(10):
        # Pool.apply_async(要调用的目标,(传递给目标的参数元祖,))
        # 每次循环将会用空闲出来的子进程去调用目标
        po.apply_async(Check_CRC,args=(i+1,))

    print("----start----")
    po.close()  # 关闭进程池，关闭后po不再接收新的请求
    po.join()  # 等待po中所有子进程执行完成，必须放在close语句之后
    print("-----end-----")
#    Check_CRC()
