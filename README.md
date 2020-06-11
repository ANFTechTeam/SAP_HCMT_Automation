Instructions:
    1. clone this repo
    2. modify variables.tf as needed
    3. terraform init
    4. terraform apply
    5. ssh and follow Chad's instructions here: https://github.com/mchad1/saphana-certification

What it does:
1. Creates an Azure Virtual Machine
2. Creates Azure NetApp Files NetApp Account
3. Creates Azure NetApp Files Capacity Pool for /hana/data
4. Creates Azure NetApp Files Capacity Pool for /hana/log
5. Creates Azure NetApp Files volume for /hana/data
6. Creates Azure NetApp Files volume for /hana/log
7. Mounts /hana/data
8. Mounts /hana/log
9. Downloads Chad Morgenstern's HCMT repository to /hana/hcmt from here: https://github.com/mchad1/saphana-certification