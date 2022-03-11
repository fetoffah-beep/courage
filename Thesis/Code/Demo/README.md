# Meteo Menu of goGPS
The addition of meteorological information such as temperature, pressure, humidity etc. has become useful to better explain the plots of ZTD, ZHD etc. produced by goGPS. In making analysis of a station data, the tool helps better understand the condition of the amtosphere at the various times and to predict their impact on the changing trends of the station's coordinates. The tool has been developed as a component of goGPS, tested on both Windows and Linux Operating Systems.

## Getting Started

### Requirements for running the tool
For running the tool in the goGPS environment, it is required to have installed both Matlab and goGPS. After processing the data using the goGPS functionality, 

- Make the figure on which the weather information is to be displayed the current figure by selecting it.
- From the command window of Matlab, type
  -  `f = gcf`. This obtains the handle to the current figure
  - `CoreUI.addMeteoMenu(f)`. This adds the Meteo menu item to the selected figure 

- From the added menu item, the meteorological parameters can then be added to the figure by selecting or deselecting the subitems of the Meteo menu.

For running the demo version of the tool,
- It is required to have from goGPS the following files
    - Exportable.m
    - GPS_Time.m
    - triPlot.m

- Also, the following files must be in the folder in which the `demo.m` file is located
    - getTimeZone.m
    - getWeatherCondition.m
    - getWeatherInfo.m

- Set the folder containing the `demo.m` file the current folder in Matlab
- Run the `demo.m` file by right clicking on it and selecting `Run` from the menu

Note: In all cases, it is required to have internet connection to have the tool function properly.