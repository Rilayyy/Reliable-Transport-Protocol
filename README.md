# Riley + Shiv

## High level description:
This project implements a reliable TCP-style layer to the origional basic UDP connection. It ensures data integrity and In-order delivery by using a number of improvements over the UDP protocol. These improvements include a sliding window mechanism, CRC32 checksums, sequence numbers, and a receiver-side buffer to handle out-of-order packets. To cleanly handle network jitter and latency, the sender calculates the RTT and using that calculates its timout intervals. Finally, the protocol features a basic congestion control which is implemented by increasing the window size for successful transmissions and drastically reducting it when dropped packets trigger timeouts.

## Problems Riley Faced: 
* Stop and wait protocol was to slow so it was causing tests that had certin time limits to fail so I implemented a sliding window protocol. I took out `self.waiting` and introduced the `self.window_size` flag and the `self.unacked_dictionary` flag which allowed the sender to keep reading from `sys.stdin` and send packets into the network as long as the number of unacked packets remained under the window limit.  

* Origionally I expierenced out of order packets. I built a reciver buffer where if a packet arrived early it got stashed in the buffer. I ony printed to a standard output when the exact sequence number it was waiting for showed up.  

* Once I added dynamic timeouts I ran into the problem of if I sent a packet, timeout, resend it, and then get an ACK I had no idea if that ACK belonged to the first or second transmission. I learned about this problem while studying for the midterm. To fix this I added a retransmitted flag to my unacked dict. I updated my ack listening loop to only calculate the new timeout interval if the packet was not retransmitted. 

