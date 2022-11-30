#!/bin/bash
echo $(echo -n $(ipfs cid format -f "%M" -b base58btc $1) | sha256sum | awk '{print $1;}') >> customdeny.txt