# Release History

* 20190416, V0.9.6
    * Improved error handling on device initialization, replaced 
      assertion with more meaningful error handling
    * Attributes for used and free memory now provide values for 
      active and available memory (see README), issue #19
    * dump mount path instead of file system path on startup
    
* 20190325, V0.9.5
    * Plugin is now based on systeminformation package 
      to support setups on Linux and Windows. MacOS should also work, 
      but is not supported.
    * Added new monitoring capabilities: 
        * Memory usage (percent): `"memoryUsedPercent"`
        * Memory free (bytes): `"memoryFree"`
        * Memory free (percent): `"memoryFreePercent"`
        * Number of processes: `"processes"`
        * System temperature (Fahrenheit ℉): `"temperatureF"`
        * WiFi received signal level (dBm): `wifiSignalLevel` 
        * Network interface throughput received (bps): `nwThroughputReceived` 
        * Network interface throughput sent (bps): `nwThroughputSent` 
        * Pimatic process uptime (seconds): `"pimaticUptime"`
     * Renamed some attributes. Device configuration will be transformed automatically, 
       but rules and variables need to be adapted manually. See README.md for details. 
  