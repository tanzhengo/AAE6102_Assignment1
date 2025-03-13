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

- If the sampling rate is too high, the function will resample the signal to speed up the acquisition process.
- The signal is converted to a lower sampling rate through bandpass filtering and downsampling.
- The resampled signal will `update settings.samplingFreq` and `settings.IF`.

Signal segmentation:

- The input signal is divided into two 1 ms signal segments `signal1` and `signal2` for subsequent correlation operations.
- Calculate the zero-mean version of the signal `signal0DC` to remove the DC component.

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

The results of data acquisition are shown in the figure:

<p align="center">
    <img src="/figure/1.jpg" alt="data acquisition" />
</p>

This table shows the tracking status and parameters of each channel in the GNSS receiver. The following is a detailed analysis of the table content:
<p align="center">
| Channel | PRN |   Frequency   |  Doppler  | Code Offset | Status |
|-----------|------------------|--------------|--------------|--------------|--------------|
|       1 |   1 |  1.20258e+03 |    1203   |      3329   |     T  |
|       2 |   3 |  4.28963e+03 |    4290   |     25173   |     T  |
|       3 |  11 |  4.09126e+02 |     409   |      1155   |     T  |
|       4 |  18 |  -3.22342e+02 |    -322   |     10581   |     T  |
|       5 | --- |  ------------ |   -----   |    ------   |   Off  |
|       6 | --- |  ------------ |   -----   |    ------   |   Off  |
|       7 | --- |  ------------ |   -----   |    ------   |   Off  |
|       8 | --- |  ------------ |   -----   |    ------   |   Off  |
|       9 | --- |  ------------ |   -----   |    ------   |   Off  |
|      10 | --- |  ------------ |   -----   |    ------   |   Off  |
|      11 | --- |  ------------ |   -----   |    ------   |   Off  |
|      12 | --- |  ------------ |   -----   |    ------   |   Off  |
</p>
Table structure
The table is divided into 6 columns, each of which has the following meaning:

`Channel`: Channel number, indicating a tracking channel in the receiver.

`PRN`: Pseudo-random noise code number (PRN) of the satellite, used to identify the satellite.

`Frequency`: Carrier frequency (unit: Hz), indicating the carrier frequency currently tracked by the receiver.

`Doppler`: Doppler shift (unit: Hz), indicating the frequency offset caused by the relative motion between the satellite and the receiver.

`Code Offset`: Code phase offset (unit: chip), indicating the code phase currently tracked by the receiver.

`Status`: Channel status, T means tracking (Tracking), Off means the channel is not in use.

## Task 2 – Tracking

The tracking phase involves adapting the tracking loop, specifically the Delay-Locked Loop (DLL), to maintain a steady lock on the satellite signals. Multiple correlators are implemented to generate correlation plots, allowing for an in-depth analysis of tracking performance. The impact of urban interference, such as multipath and signal blockage, is examined by analyzing the correlation peaks. In urban environments, reduced signal strength and distorted correlation functions can negatively affect tracking stability.

### 2.1 Analysis of Tracking Performance

This report analyzes the tracking performance of different satellites based on Carrier-to-Noise Ratio (C/N₀) and DLL (Delay Lock Loop) discriminator outputs. The Carrier-to-Noise Ratio (C/N₀) provides insights into signal strength and quality, while DLL discriminator outputs indicate tracking accuracy. Both parameters are essential in evaluating how well a GNSS receiver tracks satellite signals, especially in urban environments, where multipath and signal obstructions affect performance. The uploaded C/N₀ figures show the variation of signal quality over time for different satellites. Below is a summary of observations:

| Satellite | C/N₀ Performance | Observations |
|-----------|------------------|--------------|
| Satellite 3 | Fluctuating (30-40 dB-Hz) | Significant dips indicate weak signal or obstruction. |
| Satellite 4 | Moderate (30-40 dB-Hz) | Some variations but relatively stable tracking. |
| Satellite 8 | Weak (20-35 dB-Hz) | Frequent drops suggest interference or multipath. |
| Satellite 16 | Good (32-48 dB-Hz) | Strong and stable signal reception. |
| Satellite 22 | Moderate (30-40 dB-Hz) | Some fluctuations but remains in an acceptable range. |
| Satellite 26 | Weak (20-35 dB-Hz) | Low signal strength with occasional deep dips. |
| Satellite 27 | Strong (35-45 dB-Hz) | Good signal strength, minor fluctuations. |
| Satellite 31 | Moderate (30-40 dB-Hz) | Some instability but mostly stable tracking. |
| Satellite 32 | Weak (28-38 dB-Hz) | High fluctuations, indicating possible urban interference. |

Key Takeaways from C/N₀ Analysis:

-Satellites 16 and 27 have the best tracking conditions with strong C/N₀ values (above 35 dB-Hz) and relatively stable signals.
-Satellites 8, 26, and 32 exhibit the weakest signals, with frequent dips below 30 dB-Hz, indicating high interference or signal blockage.
-Satellites 3, 4, 22, and 31 maintain moderate signal strength, showing fluctuations but generally within an acceptable range for tracking.

By comparing C/N₀ trends with DLL discriminator outputs, we can evaluate how signal quality affects tracking accuracy.

| Satellite | DLL Stability | C/N₀ Strength | Impact on Tracking |
|-----------|---------------|----------------|--------------------|
| 3         | Poor (high fluctuations) | Moderate to weak (30-40 dB-Hz) | Tracking errors due to signal loss. |
| 4         | Moderate | Moderate (30-40 dB-Hz) | Occasional tracking instability. |
| 8         | Poor (high variations) | Weak (20-35 dB-Hz) | Severe multipath and urban interference. |
| 16        | Stable | Strong (32-48 dB-Hz) | Good tracking performance. |
| 22        | Moderate | Moderate (30-40 dB-Hz) | Some signal loss but reasonable tracking. |
| 26        | Poor (high variations) | Weak (20-35 dB-Hz) | Frequent tracking errors due to low signal strength. |
| 27        | Stable | Strong (35-45 dB-Hz) | Reliable tracking. |
| 31        | Moderate | Moderate (30-40 dB-Hz) | Some fluctuations, but mostly stable. |
| 32        | Poor (high variations) | Weak (28-38 dB-Hz) | Strong effects of urban interference. |

Key Observations:

-Strong C/N₀ (above 35 dB-Hz) correlates with stable DLL tracking (e.g., Satellites 16 and 27).
-Low C/N₀ (below 30 dB-Hz) results in erratic DLL behavior, indicating difficulty maintaining signal lock (e.g., Satellites 8, 26, and 32).
-Satellites with moderate C/N₀ (30-40 dB-Hz) experience occasional tracking issues, suggesting intermittent urban interference.

### 2.2 Summary of Findings:
In urban environments, GNSS signals are susceptible to multiple interferences that can significantly affect the quality of the correlation peak, thereby reducing the accuracy and reliability of signal tracking.

#### 2.2.1 Common interference in urban environments includes:
- Multipath interference:
After the signal is reflected by buildings, the ground, etc., it is superimposed on the direct signal, resulting in distortion of the correlation peak.
Multipath signals will introduce additional correlation peaks, or make the main peak wider and offset.
- Blockage:
Obstacles such as tall buildings and bridges will block satellite signals, resulting in a decrease in signal strength.
Blockage will reduce the amplitude of the correlation peak or even cause the signal to be completely lost.
#### 2.2.2 Effect of interference on correlation peak
- Effect of multipath interference

Correlation peak distortion:
Multipath signals will introduce additional correlation peaks, causing the main peak to become wider or offset.
The symmetry of the correlation peak is destroyed, affecting the estimation accuracy of the code phase and carrier phase.
Error of early-late correlator:
Multipath signals will cause the output of the early-late correlator to be asymmetric, increasing the code tracking error.
Change in peak amplitude:
The superposition of multipath signals may cause the amplitude of the correlation peak to fluctuate.
- Effect of shielding

Peak amplitude reduction:
When the signal is shielded, the amplitude of the correlation peak decreases significantly, which may cause signal loss.
Reduced signal-to-noise ratio:
Shielding will reduce signal strength and increase the impact of noise on the correlation peak.
Tracking interruption:
If the signal is completely shielded, the correlation peak may disappear, causing the tracking loop to lose lock.

- Best Tracking Performance: Satellites 16 and 27 (High C/N₀, stable DLL).
- Worst Tracking Performance: Satellites 8, 26, and 32 (Low C/N₀, erratic DLL).
- Moderate Tracking: Satellites 3, 4, 22, and 31 (fluctuating performance, likely urban interference effects).

## Task 3 – Navigation Data Decoding
Navigation Data Decoding is one of the key steps in GNSS receivers, which is used to extract navigation data bits from the tracked satellite signals. Navigation data contains key data such as satellite ephemeris, time information, satellite health status, etc. These data are the basis for calculating user position, velocity and time (PVT).

## Task 4 – Position and Velocity Estimation

`trackResults`: Tracking results, including the correlator output, code phase, carrier frequency, etc. for each channel.
`settings`: Receiver configuration parameters, such as sampling rate, navigation solution period, altitude mask, etc.

`navSolutions`: Navigation solution results, including pseudorange, receiver position, velocity, time, etc.
`eph`: Satellite ephemeris decoded from navigation data.

Pseudorange Measurements: These are obtained from the tracking phase and are crucial for determining the user's position and velocity. They are used as inputs to the WLS algorithm.
Weighted Least Squares (WLS) Algorithm: This algorithm is implemented in the WLSPos.m file. It calculates the user's position and velocity by minimizing the weighted sum of squared differences between the measured and predicted pseudoranges.
Position and Velocity Estimation: The receiver's position and velocity are calculated using the designed code in PosNavigation.m. The results are stored in navResults.mat, which includes:
WLSX, WLSY, WLSZ: Estimated positions in the ECEF coordinate system.
Vx, Vy, Vz: Estimated velocities in the ECEF coordinate system.
Speed: Magnitude of the velocity vector.
Visualization: The estimated trajectory is visualized by plotting the user's position and velocity. This helps in understanding the movement pattern and assessing the accuracy of the estimation.
Comparison with Ground Truth: The estimated positions are converted to geodetic coordinates (latitude and longitude) and compared with known ground truth values to evaluate accuracy.
Impact of Multipath Effects: The analysis discusses how multipath effects, caused by signal reflections, impact the WLS solution in different environments:
Open-Sky Environment: Minimal multipath effects due to dominant line-of-sight signals. The WLS estimation error is small (~5.5 meters).
Urban Environment: Significant multipath effects due to reflections from buildings, leading to larger errors (~14 meters). Non-line-of-sight reception and distorted signals degrade positioning accuracy.

## Task 5 – Kalman Filter-Based Positioning

