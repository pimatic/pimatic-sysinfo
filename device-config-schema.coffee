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
                "cpu", "memory", "memoryPercent", "processes", "temperature", "dbsize",
                "diskusage", "memoryRss", "memoryHeapUsed", "memoryHeapTotal", "uptime"
              ]
            interval:
              type: "integer"
              description: "Polling interval in ms"
              default: 10000
            path:
              type: "string"
              description: "Path (only for diskusage)"
              default: "/"
  }
}
