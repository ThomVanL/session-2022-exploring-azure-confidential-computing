#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Thomas Van Laere");
MODULE_DESCRIPTION("Hi, I am an evil module!");
MODULE_VERSION("0.1");

static int __init evil_init(void)
{
    printk(KERN_INFO "Loading evil module...\n");
    printk(KERN_INFO "Evil module has succesfully started!\n");
    return 0;
}

static void __exit evil_exit(void)
{
    printk(KERN_INFO "Evil module has stopped.\n");
}

module_init(evil_init);
module_exit(evil_exit);