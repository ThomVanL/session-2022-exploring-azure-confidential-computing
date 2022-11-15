# Azure Confidential Virtual Machine with ADM SEV-SNP

This demo is based on Microsoft's sample app for [Confidential VM Platform Guest attestation](https://github.com/Azure/confidential-computing-cvm-guest-attestation). I am (still) using [my own fork](https://github.com/ThomVanL/confidential-computing-cvm-guest-attestation) of the project, as an earlier version use Microsoft's sample used to point to a "test" endpoint of the Microsoft Azure Attestation Service. My fork will use the sharedeus production endpoint. 

## Deploy to Azure

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FThomVanL%2Fsession-2022-exploring-azure-confidential-computing%2Fmain%2Fdemos%2Fconfidential-vm-amd%2Fbicep%2Fdeploy.json)

## Demo steps to execute

Connect to the confidential VM and copy the `confidential-computing-cvm-guest-attestation` directory from `/` to the current user's home directory.

```shell
cp -r /confidential-computing-cvm-guest-attestation ~
```


```bash
# Head into the directory
cd ~/confidential-computing-cvm-guest-attestation/cvm-guest-attestation-linux-app

# Show the source code (or connect via Vs Code)
vi main.cpp

# Build the binary
cmake .
make

# Run the guest attestation process
sudo ./AttestationClient

# A jwt-token is shown, which can be decoded with
# base64 -d
```

More information regarding the payload can be found over at the "[What is guest attestation for confidential VMs?](https://learn.microsoft.com/en-us/azure/confidential-computing/guest-attestation-confidential-vms)" page. 

## Cleanup

```shell
rm -rf ~/confidential-computing-cvm-guest-attestation
```
