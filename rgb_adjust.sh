#!/bin/bash

xcalib -c && xcalib -red $1 1 100 -green $2 1 100 -blue $3 1 100 -alter
