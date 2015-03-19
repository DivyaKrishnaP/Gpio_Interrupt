gpio-interrupt is an application which polls the gpio status to wake up every 3 seconds (using poll() timeout mechanism) and is also watch
for input from stdin and for an interrupt (change in the state of the switch) from GPIO. 

Hardware:
Connect a wire from the gpio SODIMM pin you want to test to a switch.

Compiling the application:
In the application directory, run make command preceding machine(module) name.
e.g: MACHINE=colibri-t20 make
Copy the exe to the module either through ethernet and USB.
Ethernet:
scp gpio_interrupt root@10.18.0.162:/home/root
USB:
cp gpio_interrupt /media/USB

Run the application:
Run the application followed by gpio number.
e.g: ./gpio_interrupt 14

Output:
Output shows polling the gpio by printing a "." for every 3 seconds count period and for every input from stdin it prints the current status 
of gpio data.
When there is any change in the gpio input(on/off of a switch) it generates an interrupt.

