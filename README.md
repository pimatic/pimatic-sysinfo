pimatic-sysinfo
===============

pimatic plugin for displaying cpu, memory usage and temperature of the raspberry pi.

### Supported values:

* CPU usage: `"cpu"`
* Memory usage: `"memory"`
* Disk usage: `"diskusage"`
* RPI System temperature: `"temperature"`
* pimatic sqlite database size: `"dbsize"`

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
      "name": "temperature"
    }
  ]
}
```

### Credits

<div>Icon made by <a href="http://www.freepik.com" title="Freepik">Freepik</a> is licensed under <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a></div>