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

## Task 1 – Acquisition

The first step in GNSS signal processing is acquisition, where Intermediate Frequency (IF) data is processed using a GNSS Software-Defined Radio (SDR). The acquisition process aims to detect satellite signals and estimate their coarse Doppler shift and code phase. The results of the acquisition provide an initial assessment of signal availability, ensuring that the satellites can be successfully tracked in subsequent steps.

### 1.1 Signal preprocessing
Resampling:

-If the sampling rate is too high, the function will resample the signal to speed up the acquisition process.
-The signal is converted to a lower sampling rate through bandpass filtering and downsampling.
-The resampled signal will `update settings.samplingFreq` and `settings.IF`.

Signal segmentation:

-The input signal is divided into two 1 ms signal segments `signal1` and `signal2` for subsequent correlation operations.
-Calculate the zero-mean version of the signal `signal0DC` to remove the DC component.

### 1.2 Initialization parameters
Calculate the number of sampling points `samplesPerCode` for each pseudo-random code (C/A code).
Generate the phase point `phasePoints` of the local carrier signal.
Initialize the frequency search range and frequency step (default 500 Hz).
Generate the C/A code table `caCodesTable` for all satellites.

### 1.3 Coarse Acquisition
Search for each satellite PRN number:

Correlate the signal in the frequency domain and calculate the correlation value for each frequency bin and code phase.
Use Fast Fourier Transform (FFT) to speed up the correlation operation.
Find the frequency bin and code phase of the correlation peak.
Peak Detection:

Find the maximum correlation peak and calculate its ratio to the second peak `peakSize/secondPeakSize`.
If the ratio exceeds the threshold `settings.acqThreshold`, the signal is considered detected.

### 1.4 Fine Frequency Search
Perform a fine frequency search on the detected signal:
Generate a 10 ms C/A code sequence.
Remove C/A code modulation and extract the carrier signal.
Use FFT to calculate the carrier frequency and find the maximum frequency bin.

### 1.5 Downsampling Recovery
If the signal has been downsampled, restore the acquisition result to the original sampling rate:
Recalculate the code phase and carrier frequency.

### 1.6 Result Storage
Store the carrier frequency, code phase, and peak measurement of the detected satellite signal in `acqResults`.
If no signal is detected, set the carrier frequency to 0.
