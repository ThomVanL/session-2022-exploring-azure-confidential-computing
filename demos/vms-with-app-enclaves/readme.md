# Azure Virtual Machine with SGX enclaves

A demo using the [OpenEnclave SDK](https://openenclave.io/sdk/) and [scanmem](https://github.com/scanmem/scanmem). With scanmem we can try to modify the memory contents of the trusted and untrusted portions of an application enclave.

## Deploy to Azure

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FThomVanL%2Fsession-2022-exploring-azure-confidential-computing%2Fmain%2Fdemos%2Fvms-with-app-enclaves%2Fbicep%2Fdeploy.json)

## Demo steps to execute

Connect to the virtual machine with Intel SGX and copy the `session-2022-exploring-azure-confidential-computing/demos/vms-with-app-enclaves/open-enclave-sample` directory from `/` to the current user's home directory.

```shell
cp -r /session-2022-exploring-azure-confidential-computing/demos/vms-with-app-enclaves/open-enclave-sample ~
```

```bash
# Head into the directory
cd ~/open-enclave-sample

# Show the source code (or connect via Vs Code)
vi host/host.c
vi enclave/enc.c

# Show the EDL file, which is used to generates the proxy layer.
vi openenclavesample.edl

# Create the build directory
mkdir build
cd build

# Build the binary
cmake ..
make

# Run the app
host/openenclavesample_host enclave/enclave.signed
```

Once the enclave calls the `host_wait_key()` function, we can modify the untrusted portion of the application with scanmem.

``` bash
# Load scanmem with default options, which will cause it to search the memory for I32 values.
sudo scanmem $(pidof openenclavesample_host)

# Search for the value in the trusted (enclave) portion of the app.
> 123456789
# This will return no values

# Reset the filter
> reset

# Search for the value in the untrusted portion of the app.
> 987654321

# List the memory address that match the value.
> list

# Replace the <addr> with the location found with the 'list' command.
> write i32 <addr> 000000000
```

Head back to the OpenEnclave application and press enter, the the value in the untrusted portion of the app should have been changed!

## Cleanup

```shell
rm -rf ~/open-enclave-sample
```

# Credits

This demo drew inspiration from Tsuyoshi Matsuzaki's (Microsoft Japan) ["Run Application in Intel SGX Enclave (Confidential Computing)"](https://tsmatz.wordpress.com/2022/05/17/confidential-computing-intel-sgx-enclave-getting-started/) blog post. In the blog post, Tsuyoshi walks us through building a small application using the Intel SGX SDK and tries to modify the contents of the enclave's memory. I thought it would be fun to try the same experiment with the OpenEnclave SDK!
