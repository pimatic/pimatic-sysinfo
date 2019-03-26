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
                "cpu", "usedMemory", "usedMemoryPercent",
                "freeMemory", "freeMemoryPercent", "processes",
                "temperature", "temperatureF", "dbSize",
                "diskUsagePercent", "systemUptime", "wifiSignalLevel"
                "nwThroughputReceived", "nwThroughputSent",
                "pimaticRss", "pimaticHeapUsed",
                "pimaticHeapTotal", "pimaticUptime",
              ]
            interval:
              type: "integer"
              description: "Polling interval in ms"
              default: 10000
            path:
              type: "string"
              description: """
                Path (only applicable for diskUsagePercent)
              """
              default: "/"
            networkInterface:
              type: "string"
              description: """
                Network interface name (only applicable for
                wifiSignalLevel, nwThroughputReceived, and
                nwThroughputSent)
              """
              default: "wlan0"
  }
}
