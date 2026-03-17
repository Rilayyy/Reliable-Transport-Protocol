# Riley + Shiv

## High level description:
This project implements a reliable TCP-style layer to the origional basic UDP connection. It ensures data integrity and In-order delivery by using a number of improvements over the UDP protocol. These improvements include a sliding window mechanism, CRC32 checksums, sequence numbers, and a receiver-side buffer to handle out-of-order packets. To cleanly handle network jitter and latency, the sender calculates the RTT and using that calculates its timout intervals. Finally, the protocol features a basic congestion control which is implemented by increasing the window size for successful transmissions and drastically reducting it when dropped packets trigger timeouts.

## Properties / features of the design:

* **Sliding window sender**: The sender can have multiple packets in flight at once, controlled by a window size. This allows much higher throughput than a stop-and-wait protocol.
* **Receiver-side reordering buffer**: The receiver buffers out-of-order packets keyed by sequence number and only prints when the next expected sequence arrives, guaranteeing in-order delivery.
* **Duplicate detection**: If the receiver gets a packet with a sequence number lower than `next_expected`, it treats it as a duplicate, does not print it again, but still sends an ACK so the sender can safely clear it.
* **Loss detection and retransmission**: The sender tracks unacked packets with send timestamps. When the current time minus the send time exceeds the timeout interval, it retransmits the packet and treats this as a sign of loss/congestion.
* **RTT-based timeouts**: The sender maintains an exponentially smoothed RTT estimate and deviation and sets its timeout interval based on these values, so it adapts to both slow and fast networks.
* **Adaptive window sizing (basic congestion control)**: when successful, non-retransmitted ACKs the window size grows; on timeouts it is cut down (with a minimum). This additive-increase/multiplicative-decrease pattern helps balance throughput and stability
* **Checksum-based corruption handling**: Every data and ACK packet has a CRC32 checksum. Both sides verify the checksum and drop any corrupted packets, treating them as lost so corrupted data is never printed and corrupted ACKs never affect the sender’s state.

## Problems/Challenges Riley Faced: 
* Stpp and wait protocol was to slow so it was causing tests that had certin time limits to fail so I implemented a sliding window protocol. I took out `self.waiting` and introduced the `self.window_size` flag and the `self.unacked_dictionary` flag which allowed the sender to keep reading from `sys.stdin` and send packets into the network as long as the number of unacked packets remained under the window limit.  

* Origionally I expierenced out of order packets. I built a reciver buffer where if a packet arrived early it got stashed in the buffer. I ony printed to a standard output when the exact sequence number it was waiting for showed up.  

* Once I added dynamic timeouts I ran into the problem of if I sent a packet, timeout, resend it, and then get an ACK I had no idea if that ACK belonged to the first or second transmission. I learned about this problem while studying for the midterm. To fix this I added a retransmitted flag to my unacked dict. I updated my ack listening loop to only calculate the new timeout interval if the packet was not retransmitted. 

## Problems/Challenges Shiv Faced: 
* Integrating CRC32 checksums into both the sender and receiver so that corrupted data and ACK packets are detected and dropped without breaking earlier levels. This required changing how packets are built, parsed, and validated while keeping the rest of the logic the same.

* Implementing RTT-based dynamic timeouts and tuning the parameters so that the sender works across slow and fast configs without timing out too aggressively or taking too long to retransmit lost packets.

* Adding adaptive window growth and a maximum window cap to balance throughput and total bytes sent. I had to experiment with different caps and observe the "Stats:" output to avoid too many retransmissions on lossy configs.

## Testing overview:

* We used the provided run script with the individual config files to debug specific behaviors, such as basic reliability, reordering, loss, corruption, and variable latency.

* After each major feature (sliding window, receiver buffer, retransmission logic, checksums, RTT adaptation, and adaptive window sizing), we re-ran the earlier levels (1–4) to ensure we did not break correctness while adding new functionality.

* Once the core implementation was stable, we ran the test script to execute all of the public configurations in one go and confirm that our code passed all the testss.

* For performance, we compared the reported "Stats:" lines (total time, bytes, and packets sent) across multiple runs and tuned the window growth/shrink behavior and timeout parameters to reduce both completion time and total bytes sent while preserving correctness.