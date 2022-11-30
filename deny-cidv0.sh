#!/bin/bash
echo $(echo -n $1 | sha256sum | awk '{print $1;}') >> customdeny.txt