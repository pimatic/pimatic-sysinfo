pimatic-sysinfo
=======================

pimatic plugin for displaying cpu, memory usage and temperature of the raspberry pi.

```json
{
  "class": "SystemSensor",
  "id": "syssensor",
  "name": "system",
  "attributes": [
    {
      "name": "cpu"
    },
    {
      "name": "memory"
    },
    {
      "name": "temperature"
    }
  ]
}
```
