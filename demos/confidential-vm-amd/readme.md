# Azure Confidential Virtual Machine with ADM SEV-SNP

## Deploy to Azure

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FThomVanL%2Fsession-2022-exploring-azure-confidential-computing%2Fmain%2Fdemos%2Fconfidential-vm-amd%2Fbicep%2Fdeploy.json)

## Demo steps to execute

Connect to the confidential VM and copy the `confidential-computing-cvm-guest-attestation` directory from `/` to the current user's home directory.

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