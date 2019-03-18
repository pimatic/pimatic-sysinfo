pimatic-sysinfo
===============

Plugin for displaying cpu, memory usage and temperature of the pimatic system. It supports pimatic setups on 
Windows, Linux, and MacOS.

### Supported values:

* CPU usage (percent): `"cpu"`
* Memory usage (bytes): `"memory"`
* Memory usage (percent): `"memoryPercent"`
* Disk usage (percent) for a single mount point: `"diskusage"`
* Number of processes: `"processes"`
* System temperature (Celsius ℃): `"temperature"`
* System temperature (Fahrenheit ℉): `"temperatureF"`
* System uptime in seconds: `"uptime"`
* Pimatic SQLite database size (bytes): `"dbsize"`
* Pimatic process RSS memory (bytes): `"rss"`
* Pimatic process used heap memory (bytes): `"heapUsed"`
* Pimatic process total heap memory (bytes): `"heapTotal"`

Notes:
* RSS is the amount of space occupied in the main memory device 
  (that is a subset of the total allocated memory) for the 
  process, which includes the heap, code segment and stack
  
### Plugin Configuration

```
{ 
  "plugin": "sysinfo"
}
```

### Device Configuration

#### Examples:

```json
{
  "class": "SystemSensor",
  "id": "syssensor",
  "name": "System",
  "attributes": [
    {
      "name": "cpu"
    },
    {
      "name": "memory"
    },
    {
      "name": "diskusage",
      "path": "/"
    }
  ]
}
```


```json
{
  "class": "SystemSensor",
  "id": "syssensor",
  "name": "System Temp.",
  "attributes": [
    {
      "name": "temperature",
      "interval": 5000
    }
  ]
}
```

### Trouble Shooting

* The value for `temperature` is -1
    
  On Windows, admin privileges are required in some setups to query the 
  temperature with the underlying `wmic` tool. If you're running on Linux,
  please report an issue with the Linux distribution, version and hardware 
  used.
  
* I would like to display the uptime in a human readable format

  You can set the `displayFormat xAttributeOption` for attribute `uptime`to the
  value `uptime`. 

### Credits

<div>Icon made by <a href="http://www.freepik.com" title="Freepik">Freepik</a> is licensed under <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a></div>
