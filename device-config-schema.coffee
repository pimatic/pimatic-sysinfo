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
  }
}
