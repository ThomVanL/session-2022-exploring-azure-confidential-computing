# Trusted Launch - Untrusted Linux Kernel module

Trusted launch is integrated with Azure Defender for Cloud to ensure your VMs are properly configured. Azure Defender for Cloud will continually assess compatible VMs and issue relevant recommendations.

## Deploy to Azure

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FThomVanL%2Fsession-2022-exploring-azure-confidential-computing%2Fmain%2Fdemos%2Ftrusted-launch%2Fbicep%2Fdeploy.json)

## Demo steps to execute

Connect to the trusted launch VM and copy the `/session-2022-exploring-azure-confidential-computing/demos/trusted-launch/evil-module` directory from `/` to the current user's home directory.

```shell
cp -r /session-2022-exploring-azure-confidential-computing/demos/trusted-launch/evil-module ~
```

Perform the following actions inside the `evil-module` directory:

```shell
# Build kernel module
make

# We can see the info of the module
modinfo evil.ko

# However, if we secure boot enabled in azure,
# We will not be able to insert the module into the kernel
sudo insmod evil.ko
tail /var/log/kern.log

# We can verify that secure boot was enabled.
mokutil --sb-state

# Removing won't do much either since it was not loaded.
sudo rmmod evil.ko

# Let's make it so our driver is loaded when the system starts
# Perhaps we can trick the system into
# Create the driver directory
sudo mkdir -p /lib/modules/$(uname -r)/kernel/drivers/evil

# Copy the built module
sudo cp ~/evil-module/evil.ko /lib/modules/$(uname -r)/kernel/drivers/evil/evil.ko

# Tell the OS to load the drivers at boot
echo "kernel/drivers/evil/evil.ko" | sudo tee -a /lib/modules/$(uname -r)/modules.dep
echo "kernel/drivers/evil/evil.ko" | sudo tee -a /lib/modules/$(uname -r)/modules.order
echo "evil" | sudo tee -a /etc/modules-load.d/evil.conf

# Since modprobe has an internal cache, we must update it.
sudo depmod -a

# Reboot machine
sudo reboot

# Try to read from the kernel ring buffer
sudo dmesg | grep Evil
```

## Cleanup

```shell
sudo dmesg --clear
sudo rm -rf /lib/modules/$(uname -r)/kernel/drivers/evil
sudo sed -i "s|kernel/drivers/evil/evil.ko||g" /lib/modules/$(uname -r)/modules.dep /lib/modules/$(uname -r)/modules.order
sudo rm /etc/modules-load.d/evil.conf
sudo depmod -a
rm -rf ~/evil-module
```