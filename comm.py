# Hanover Displays flip-dot display frame generator
# Furrtek 10/2017
# I don't like Python :(

import time
import serial

text = "HONK IF HORNY"
data = [ 0xFF, 0x41 ]

ser = serial.Serial("COM2", baudrate=4800, parity=serial.PARITY_ODD)

data.append(len(text))

for char in text:
	data.append(ord(char))

checksum = 0
for byte in data[1:]:
	checksum ^= byte
data.append(checksum)

print data

for byte in data:
	ser.write(chr(byte))
