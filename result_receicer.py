from serial import Serial, EIGHTBITS, PARITY_NONE, STOPBITS_ONE
from sys import argv

assert len(argv) == 2
s = Serial(
    port=argv[1],
    baudrate=115200,
    bytesize=EIGHTBITS,
    parity=PARITY_NONE,
    stopbits=STOPBITS_ONE,
    xonxoff=False,
    rtscts=False
)

fp_dec = open('result.bin', 'wb')
assert fp_dec

dec = s.read(31)
fp_dec.write(dec)

fp_dec.close()
