#!/usr/bin/env python3

import argparse, socket, time, json, select, struct, sys, math

class Receiver:
    def __init__(self):
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.socket.bind(('0.0.0.0', 0))
        self.port = self.socket.getsockname()[1]
        self.log("Bound to port %d" % self.port)

        self.remote_host = None
        self.remote_port = None
        self.next_expected = 0
        self.buffer = {}  # seq -> data

    def send(self, message):
        self.log("Sent message %s" % json.dumps(message))
        self.socket.sendto(json.dumps(message).encode("utf-8"), (self.remote_host, self.remote_port))

    def recv(self, socket):
        data, addr = socket.recvfrom(65535)

        # Grab the remote host/port if we don't already have it
        if self.remote_host is None:
            self.remote_host = addr[0]
            self.remote_port = addr[1]

        # Make sure we're talking to the same remote host
        if addr != (self.remote_host, self.remote_port):
            self.log("Error:  Received response from unexpected remote; ignoring")
            return None
        else:
            self.log("Received message %s" % data.decode("utf-8"))
            return json.loads(data.decode("utf-8"))

    def log(self, message):
        sys.stderr.write(message + "\n")
        sys.stderr.flush()

    def run(self):
        while True:
            socks = select.select([self.socket], [], [])[0]
            for conn in socks:
                msg = self.recv(conn)

                if msg and "seq" in msg and "data" in msg:
                    seq = int(msg["seq"])
                    if seq < self.next_expected:
                        # Duplicate: ACK so sender can clear, do not print
                        self.send({"type": "ack", "seq": msg["seq"]})
                    else:
                        # In-order or out-of-order: store and drain in order
                        self.buffer[seq] = msg["data"]
                        while self.next_expected in self.buffer:
                            sys.stdout.write(self.buffer[self.next_expected])
                            sys.stdout.flush()
                            del self.buffer[self.next_expected]
                            self.next_expected += 1
                        self.send({"type": "ack", "seq": msg["seq"]})

        return

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='receive data')
    args = parser.parse_args()
    sender = Receiver()
    sender.run()
