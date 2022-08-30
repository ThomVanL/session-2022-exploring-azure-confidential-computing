// Copyright (c) Open Enclave SDK contributors.
// Licensed under the MIT License.

#include <openenclave/host.h>
#include <stdio.h>

// Include the untrusted openenclavesample header that is generated
// during the build. This file is generated by calling the
// sdk tool oeedger8r against the openenclavesample.edl file.
#include "openenclavesample_u.h"

bool check_simulate_opt(int *argc, const char *argv[])
{
    for (int i = 0; i < *argc; i++)
    {
        if (strcmp(argv[i], "--simulate") == 0)
        {
            fprintf(stdout, "Running in simulation mode\n");
            memmove(&argv[i], &argv[i + 1], (*argc - i) * sizeof(char *));
            (*argc)--;
            return true;
        }
    }
    return false;
}

void host_wait_key()
{
    printf("Press enter to continue:");
    getchar();
}

int main(int argc, const char *argv[])
{
    printf("\nValues on start:\n");
    int changeMe = 987654321;
    printf("Value for changeMe (host): %d\n", changeMe);

    oe_result_t result;
    int ret = 1;
    oe_enclave_t *enclave = NULL;

    uint32_t flags = OE_ENCLAVE_FLAG_DEBUG;
    if (check_simulate_opt(&argc, argv))
    {
        flags |= OE_ENCLAVE_FLAG_SIMULATE;
    }

    if (argc != 2)
    {
        fprintf(
            stderr, "Usage: %s enclave_image_path [ --simulate  ]\n", argv[0]);
        goto exit;
    }

    // Create the enclave
    result = oe_create_openenclavesample_enclave(
        argv[1], OE_ENCLAVE_TYPE_AUTO, flags, NULL, 0, &enclave);
    if (result != OE_OK)
    {
        fprintf(
            stderr,
            "oe_create_openenclavesample_enclave(): result=%u (%s)\n",
            result,
            oe_result_str(result));
        goto exit;
    }

    // Call into the enclave
    if (enclave)
    {
        int *enclaveValue = malloc(sizeof(int));
        result = enclave_set_secret_value(enclave, enclaveValue);
        if (result != OE_OK)
        {
            fprintf(
                stderr,
                "calling into enclave_set_secret_value failed: result=%u (%s)\n",
                result,
                oe_result_str(result));
            goto exit;
        }

        printf("\nValues on exit:\n");
        printf("Value for changeMe (host): %d\n", changeMe);
        printf("Value for changeMe (enclave): %d\n", *enclaveValue);
    }
    ret = 0;
exit:
    // Clean up the enclave if we created one
    if (enclave)
    {
        oe_terminate_enclave(enclave);
    }

    return ret;
}
