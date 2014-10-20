pimatic-sysinfo
=======================

pimatic plugin for displaying cpu, memory usage and temperature of the raspberry pi.

### Supported values:

* CPU usage: `"cpu"`
* Memory usage: `"memory"`
* Disk usage: `"diskusage"`
* RPI System temperature: `"temperature"`
* pimatic sqlite database size: `"dbsize"`

```
{ 
  "plugin": "sysinfo"
}
```

### Examples:

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
