module.exports = {
  title: "pimatic-sysinfo device config schemas"
  SystemSensor: {
    title: "SystemSensor config options"
    type: "object"
    extensions: ["xLink", "xAttributeOptions"]
    properties:
      attributes:
        description: "Attributes of the device"
        type: "array"
        default: [{name: "cpu"},{name: "memory"}]
        items:
          type: "object"
          properties:
            name:
              type: "string"
              description: "The sensor"
              enum: [
                "cpu", "memory", "memoryPercent", "processes",
                "temperature", "temperatureF", "dbSize",
                "diskUsage", "memoryRss", "memoryHeapUsed",
                "memoryHeapTotal", "uptime", "wifiSignalLevel"
              ]
            interval:
              type: "integer"
              description: "Polling interval in ms"
              default: 10000
            path:
              type: "string"
              description: "Path (only for diskusage)"
              default: "/"
            wifiInterface:
              type: "string"
              description: "WiFi network interface name (only for wifiSignalLevel)"
              default: "wlan0"
  }
}
