import sys
import re
from web3 import Web3

returnText = sys.argv[1]

isDivisible = False

address = re.search(r'0x[A-Fa-f0-9]+', returnText)[0]
salt = re.search(r'Salt: ([0-9]+)', returnText)[0]
salt = re.search(r'[0-9]+', salt)[0]

uintAddress = Web3.toInt(hexstr=address)

isDivisible = (uintAddress % 100) == 10

print(isDivisible)