# AAE6102_Assignment1

## Overview

This repository contains the report and code for Assignment 1 of the AAE6102 Satellite Communication and Navigation course. The assignment focuses on Global Navigation Satellite System (GNSS) signal processing, including acquisition, tracking, navigation data decoding, position and velocity estimation, and the implementation of an Extended Kalman Filter (EKF) for improved positioning accuracy.

### Step-by-step instructions

#### 0. Copy data files
First, you need to put the data files `Urban.dat` and `Opensky.bin` in the `~/GPS_L1_CA/data` path. It should looks like:

```
GPS_L1_CA/
├── Common
└── data/
    ├── Urban.dat
    ├── Opensky.bin
    └── ...
```
#### 1. Run the code
After that, run the code `init.m`. When you see the following message displayed in the terminal, enter `1` and press Enter.

```
-------------------------------

Probing data (data/Urban.dat)...
  Raw IF data plotted 
  (run setSettings or change settings in "initSettings.m" to reconfigure)
 
Enter "1" to initiate GNSS processing or "0" to exit : 
```
