# Load Config file.
$env_file_name = $args[0]
ls $env_file_name | Out-Null
if($? -eq $false){"env file not found."; exit}
. $env_file_name

$config_file_name = $args[1]
ls $config_file_name | Out-Null
if($? -eq $false){"config file not found."; exit}
. $config_file_name

# Load Functions
. ./parts/functions.ps1

# Generate VM / ESXi List
$vm_name_list = gen_vm_name_list $vm_num $hv_ip_4oct_start $hv_ip_prefix_vmk0
$nest_hv_hostname_list = gen_nest_hv_hostname_list $vm_num $hv_ip_4oct_start $nest_hv_hostname_prefix
$hv_ip_vmk0_list = gen_hv_ip_vmk0_list $vm_num $hv_ip_4oct_start $hv_ip_prefix_vmk0
$vc_hv_name_list = $hv_ip_vmk0_list

# Adjast Setup Flag
if($create_vsan_cluster -eq $true){$create_vsphre_cluster = $true}
if($create_vsphre_cluster -eq $true){$create_esxi_vms = $true}

task_message "Main-00" "Disconnect from All vCeners"
disconnect_all_vc

if($create_vsphre_cluster -eq $true){
    task_message "Main-00_Start" "Create vSphere Cluster"
    connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass
    ./parts/step_2-1a_create-vsphere-cluster.ps1
    
    task_message "Main-00_End" "Create vSphere Cluster"
    disconnect_all_vc
}

if($create_esxi_vms -eq $true){
    task_message "Main-01_Start" "Setup Base-vSphere"
    connect_vc -vc_addr $base_vc_address -vc_user $base_vc_user -vc_pass $base_vc_pass
    ./parts/step_1-1_clone-esxi-vms_for-vsan.ps1
    ./parts/step_1-2_config-esxi-guest_for-vsan.ps1

    task_message "Main-01_End" "Setup Base-vSphere"
    disconnect_all_vc
}

if($create_vsphre_cluster -eq $true){
    task_message "Main-02_Start" "Setup Nested-vSphere"
    connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass
    ./parts/step_2-1b_setup-vsphere-cluster.ps1
    ./parts/step_2-2_create-vmk-port_on-vss.ps1

    task_message "Main-02_End" "Setup Nested-vSphere"
    disconnect_all_vc
}

if($create_witness_vm -eq $true){
    task_message "Witness-1_Start" "Setup Witness-Host VA"
    connect_vc -vc_addr $base_vc_address -vc_user $base_vc_user -vc_pass $base_vc_pass
    ./parts/Witness/step-1_clone-vSAN-Witness-VA.ps1

    task_message "Witness-1_End" "Disconnect from All vCeners"
    disconnect_all_vc

    task_message "Witness-2_Start" "Setup Witness-Host Guest"
    connect_vc -vc_addr $base_vc_address -vc_user $base_vc_user -vc_pass $base_vc_pass
    ./parts/Witness/step-2_config-vSAN-Witness-VA-Guest.ps1

    task_message "Witness-2_End" "Disconnect from All vCeners"
    disconnect_all_vc

    task_message "Witness-3_Start" "Setup Witness-Host on vCenter"
    connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass
    ./parts/Witness/step-3_add-vSAN-Witness-Host-WTS.ps1

    task_message "Witness-3_End" ("Disconnect from All vCeners")
    disconnect_all_vc
}

if($create_vsan_wts -eq $true){
    task_message "Witness-4_Start" "Setup vSAN Witness Data Host"
    connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass
    ./parts/step_3-1a_setup-vsan-witness-nw.ps1
    
    task_message "Witness-4_End" "Setup vSAN Witness Data Host"
    disconnect_all_vc
}

if($create_vsan_cluster -eq $true){
    task_message "Main-04_Start" "Setup vSAN"
    connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass
    ./parts/step_3-1_setup-vsan-disk.ps1
    ./parts/step_3-2_setup-vsan-cluster.ps1

    task_message "Main-04_End" "Setup vSAN"
    disconnect_all_vc
}

if($vsan_dg_count){
    for($i=2; $i -le $vsan_dg_count; $i++){
        task_message "AddDG-01_Start" "Add VMDK for vSAN Disk Group"
        connect_vc -vc_addr $base_vc_address -vc_user $base_vc_user -vc_pass $base_vc_pass
        ./parts/step_5-1_add-vsan-vmdk.ps1

        task_message "AddDG-01_End" "Add VMDK for vSAN Disk Group"
        disconnect_all_vc

        task_message "AddDG-02_Start" "Add vSAN Disk Group"
        connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass
        ./parts/step_5-2_fix-disk-type.ps1
        ./parts/step_5-3_add-vsan-dg.ps1

        task_message "AddDG-02_End" "Add vSAN Disk Group"
        disconnect_all_vc
    }
}

if($create_vsan_2node -eq $true){
    task_message "Main-05_Start" "Setup 2-Node vSAN"
    connect_vc -vc_addr $nest_vc_address -vc_user $nest_vc_user -vc_pass $nest_vc_pass
    ./parts/Witness/step-4_create-vSAN-Cluster-2Node.ps1
    task_message "Main-05_End" "Setup 2-Node vSAN"
    disconnect_all_vc
}
