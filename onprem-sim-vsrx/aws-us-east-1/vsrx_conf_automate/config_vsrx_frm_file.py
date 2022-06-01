#!/Library/Frameworks/Python.framework/Versions/3.10/bin/python3
from distutils.command.upload import upload
from jinja2 import Environment, FileSystemLoader
import os
import argparse
import subprocess
import json
import netmiko
import time

def update_vsrx_data_file(get_tf_mod_info):
    script_dir = os.getcwd()
    cmd_vsrx_info = f'terraform output -json {tf_mod_op_info["tf_vsrx_op_name"]}'
    os.chdir(tf_mod_op_info["tf_vsrx_mod_loc"])
    tf_op_vsrx = subprocess.run(cmd_vsrx_info.split(),capture_output=True,text=True)
    #print(tf_op_vsrx.stdout)
    #print(tf_op_vsrx.args)
    #print(tf_op_vsrx.returncode)
    #print(tf_op_vsrx.stderr)
    vsrx_info = json.loads(tf_op_vsrx.stdout)
    #print(vsrx_info)
    os.chdir(tf_mod_op_info["tf_avx_conn_loc"])
    cmd_cnx_detail = f'terraform output -json {tf_mod_op_info["tf_avx_op_name"]}'
    tf_op_cnx1 = subprocess.run(cmd_cnx_detail.split(),capture_output=True,text=True)
 
    #print(tf_op_cnx1.stdout)
    #print(tf_op_cnx1.args)
    #print(tf_op_cnx1.returncode)
    #print(tf_op_cnx1.stderr) 

    cnx_info = json.loads(tf_op_cnx1.stdout)
    # changing back to directory where script was invoked from
    os.chdir(script_dir)
    vsrx_data = {}
    iter = 1

    for key , value in vsrx_info.items():
        vsrx_data[key] = {}
        vsrx_data[key]["fxp0_pvt_ip"] = value["fxp0_pvt_ip"]
        vsrx_data[key]["fxp0_pub_ip"] = value["fxp0_pub_ip"] 
        vsrx_data[key]["internet_pvt_ip"] = value["internet_pvt_ip"]
        vsrx_data[key]["internet_pub_ip"] = value["internet_pub_ip"]
        vsrx_data[key]["lan_pvt_ip"] = value["lan_pvt_ip"] + "/24" 
        vsrx_data[key]["tunnel_primary_gw_ip"] = get_local_tun_ip(remote_pri_tun_ip,iter) + "/30"
        vsrx_data[key]["tunnel_hagw_ip"] = get_local_tun_ip(remote_pri_ha_tun_ip,iter) + "/30"
        vsrx_data[key]["remote_gw_as"] = avx_xt_gw_as
        vsrx_data[key]["remote_pri_tunnel_ip"] = get_remote_tun_ip(iter,cnx_info,"pri")
        vsrx_data[key]["remote_ha_tunnel_ip"] = get_remote_tun_ip(iter,cnx_info,"ha")
        vsrx_data[key]["primary_gw_remote_ip"] = cnx_info["avx_pri_gw_pubip"]
        vsrx_data[key]["ha_gw_remote_ip"] = cnx_info["avx_ha_gw_pubip"]
        vsrx_data[key]["management_df_gw"] = get_defgwip(value["fxp0_pvt_ip"])
        vsrx_data[key]["internet_gw_ip"] = get_defgwip(value["internet_pvt_ip"])
        vsrx_data[key]["main_as_num"] = vsrx_as
        vsrx_data[key]["psk"] = "Juniper123#"
#----
        iter += 1 

    with open('vsrx_data.json','w') as vsrx_f:
        json.dump(vsrx_data,vsrx_f,indent=4)

def get_defgwip(ip):
    ip_octets = ip.split(".")
    ip_octets[3] = "1"
    df_gw_ip = ".".join(ip_octets)
    return df_gw_ip

def get_slash24subnet(ip):
    ip_octets = ip.split(".")
    ip_octets[3] = "0"
    subnet = ".".join(ip_octets)+ "/24"
    return subnet

def get_local_tun_ip(ip,iter):
  #  ip = ip.split("/")[0]
    if iter == 1:
        ip_octets = ip.split(".")
        ip_octets[3] = "2"
        local_tun_ip = ".".join(ip_octets)
        return local_tun_ip
    elif iter == 2:
        ip_octets = ip.split(".")
        ip_octets[2] = str(int(ip_octets[2]) + 10)
        ip_octets[3] = "2"
        local_tun_ip = ".".join(ip_octets)
        return local_tun_ip

def get_remote_tun_ip(iter,cnx_info,gw):
      #  ip = ip.split("/")[0]
    if iter == 1 and gw == "pri":
        return cnx_info["tunnel_ip_pri_gw"].split("/")[0]
    elif iter == 1 and gw == "ha":
        return cnx_info["tunnel_ip_ha_gw"].split("/")[0]
    elif iter == 2 and gw == "pri":
        return cnx_info["backup_tunnel_ip_pri_gw"].split("/")[0]
    elif iter ==2 and gw == "ha": 
        return cnx_info["backup_tunnel_ip_ha_gw"].split("/")[0]


def get_var_data_frm_file(fname="vsrx_data.json"):
    
    with open('vsrx_data.json','r') as f:
        conf_data = json.load(f)

    return conf_data 

def create_vsrx_config_file(conf_data):
    conf_files = []
    for key in conf_data:
        
        data = conf_data[key]
        loader = FileSystemLoader("templates")
        environment = Environment(loader=loader)
        tpl = environment.get_template("vsrx_ipsec.jinja")
        tpl.stream(internet_pvt_ip = data["internet_pvt_ip"]+"/24",
            lan_pvt_ip =  data["lan_pvt_ip"],
            tunnel_primary_gw_ip = data["tunnel_primary_gw_ip"],
            tunnel_hagw_ip = data["tunnel_hagw_ip"],
            primary_gw_remote_ip = data["primary_gw_remote_ip"],
            internet_gw_ip = data["internet_gw_ip"],
            ha_gw_remote_ip = data["ha_gw_remote_ip"],
            management_df_gw = data["management_df_gw"],
            main_as_num = data["main_as_num"],
            psk = data["psk"],
            internet_pub_ip = data["internet_pub_ip"],
            fxp0_pvt_ip = data["fxp0_pvt_ip"],
            fxp0_pub_ip = data["fxp0_pub_ip"],
            remote_pri_tunnel_ip = data["remote_pri_tunnel_ip"],
            remote_ha_tunnel_ip = data["remote_ha_tunnel_ip"],
            local_pri_tunnel_ip = data["tunnel_primary_gw_ip"].split('/')[0],
            remote_gw_as = data["remote_gw_as"],
            local_ha_tunnel_ip = data["tunnel_hagw_ip"].split('/')[0],
            lan_pvt_subnet = get_slash24subnet(data["lan_pvt_ip"])
            ).dump(key+".conf")
        conf_file_ip_tmp = (f'{key}.conf',data["fxp0_pub_ip"])
        conf_files.append(conf_file_ip_tmp)
    return conf_files 

def config_vsrx(conf_files,ssh_key_path):
    # Each tuple has file name , fxp0 pub ip

    for info in conf_files:
        # upload file to Juniper based on host ip
        conf_file = "/var/tmp/vsrx_config.cfg"
        conf_commands = [f'load set {conf_file}']
        vsrx_dev = {
            "device_type": "juniper_junos",
            "host": info[1],
            "username" : "ec2-user",
            "use_keys" : True,
            "key_file" : ssh_key_path
            }

        ssh_conn = netmiko.ConnectHandler(**vsrx_dev)
        file_xfer_resp = netmiko.file_transfer(ssh_conn,
        source_file=info[0],
        dest_file="vsrx_config.cfg",
        file_system= "/var/tmp",
        direction="put",
        overwrite_file=True,
        )
        print(file_xfer_resp)
        with ssh_conn as ssh_connect:
            conf_op = ssh_connect.send_config_set(conf_commands,exit_config_mode=False)
            print(conf_op)
            commit_op = ssh_connect.commit(and_quit=True)
            print(commit_op)
            time.sleep(30)
            ike_op = ssh_connect.send_command(f'show security ike security-associations')
            bgp_op = ssh_connect.send_command(f'show bgp summary')
            print(ike_op)
            print(bgp_op)

def get_ssh_pub_key_path():
    key_path = input("""Please enter your ssh public key absolute path for sshing into vSRX: \n
    Enter "default" if its your default ssh key: \n""")

    if key_path.lower() == "default":
        return "~/.ssh/id_rsa.pub"
    else: 
        return key_path 

def get_tf_mod_info():
    tf_mod_op_info = {}
    tf_mod_op_info["tf_vsrx_mod_loc"] = input("Please enter the absolute full path of your tf vsrx module: ")
    tf_mod_op_info["tf_vsrx_op_name"] = input("Please enter the vsrx module output name: ")
    tf_mod_op_info["tf_avx_conn_loc"] = input("Please enter the absolute full path of your tf avitrix conn module: ")
    tf_mod_op_info["tf_avx_op_name"] = input("Please enter the avx conn module output name: ")
    return tf_mod_op_info
    
# start main 
if __name__=="__main__":
    # Static variables defenition
    # all these are /30 
    ssh_key_path = get_ssh_pub_key_path()
    remote_pri_tun_ip = "169.254.1.1"
    remote_pri_ha_tun_ip = "169.254.2.1"
    remote_backup_tun_ip = "169.254.11.1"
    remote_backup_ha_tun_ip = "169.254.12.1"
    avx_xt_gw_as = "65500"
    vsrx_as = "65512"

    tf_mod_op_info = get_tf_mod_info()
    update_vsrx_data_file(get_tf_mod_info)
    conf_data = get_var_data_frm_file(fname="vsrx_data.json")
    config_files = create_vsrx_config_file(conf_data)
    config_vsrx(config_files,ssh_key_path)



