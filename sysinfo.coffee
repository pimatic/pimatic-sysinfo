module.exports = (env) ->

  # Require the  bluebird promise library
  Promise = env.require 'bluebird'

  # Require the [cassert library](https://github.com/rhoot/cassert).
  assert = env.require 'cassert'

  fs = env.require 'fs'
  Promise.promisifyAll(fs)

  si = require('systeminformation')


  wifiStatus = (ifName) ->
    if process.platform is 'linux'

      parseBlock = (block) ->
        parsed = undefined
        if block?
          parsed = {
            interface: block.match(/^([^\s]+)/)[1]
          }
          if (match = block.match(/Signal level[:|=]\s*(-?[0-9]+)/))
            parsed.signal = parseInt(match[1], 10);
        return parsed

      parseStatusInterface = (callback) ->
        return (error, stdout, stderr) ->
          if (error)
            callback(error)
          else
            callback(error, parseBlock(stdout.trim()))

      return new Promise (resolve, reject) ->
        (require 'child_process').exec('iwconfig ' + ifName,
          parseStatusInterface (err, data) ->
            if err?
              reject err
            else
              resolve data
          )
    else
      throw new Error("WiFi signal strength monitoring is only supported on Linux")


  class SysinfoPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>
      deviceConfigDef = require("./device-config-schema")

      @framework.deviceManager.registerDeviceClass("SystemSensor", {
        prepareConfig: SystemSensor.prepareConfig,
        configDef: deviceConfigDef.SystemSensor, 
        createCallback: (config) => return new SystemSensor(config, @framework)
      })
      si.fsSize().then( (data) ->
        env.logger.info('Mounted File Systems: ' + data.map((el) -> el.fs).join(", "))
      )
      si.networkInterfaces().then( (data) ->
        env.logger.info('Network Interfaces: ' + data.map((el) -> el.iface).join(", "))
      )

  # ##SystemSensor Sensor
  class SystemSensor extends env.devices.Sensor
    @prepareConfig: (config) =>
      rename =
        diskusage: 'diskUsagePercent'
        dbsize: 'dbSize'
        memory: 'usedMemory'
        memoryPercent: 'usedMemoryPercent'
        uptime: 'systemUptime'
      keys = Object.keys
      for attr in config.attributes
        do (attr) =>
          for key, val of rename
            if attr.name is key
              attr.name = val
              break

    constructor: (@config, framework) ->
      @id = @config.id
      @name = @config.name

      @attributes = {}
      # initialise all attributes
      for attr, i in @config.attributes
        do (attr) =>
          name = attr.name
          assert name in [
            'cpu', 'usedMemory', 'usedMemoryPercent',
            'freeMemory', 'freeMemoryPercent', 'processes',
            'temperature', 'temperatureF', 'dbSize', 'diskUsagePercent',
            'memoryRss','memoryHeapUsed', 'memoryHeapTotal',
            'pimaticUptime', 'systenUptime', 'wifiSignalLevel',
            'nwThroughputReceived', 'nwThroughputSent'
          ]

          @attributes[name] = {
            description: name
            type: "number"
          }

          switch name
            when "cpu"
              getter = ( =>
                return si.currentLoad().then( (res) =>
                  return Math.round(res.currentload * 10) / 10
                )
              )
              @attributes[name].unit = '%'
              @attributes[name].acronym = 'CPU'
            when "usedMemory"
              getter = ( =>
                return si.mem().then( (res) ->
                  return res.used
                )
              )
              @attributes[name].unit = 'B'
              @attributes[name].acronym = 'M USED'
            when "usedMemoryPercent"
              getter = ( =>
                return si.mem().then( (res) ->
                  return Math.round(res.used / res.total * 1000) / 10
                )
              )
              @attributes[name].unit = '%'
              @attributes[name].acronym = 'M USED%'
            when "freeMemory"
              getter = ( =>
                return si.mem().then( (res) ->
                  return res.free
                )
              )
              @attributes[name].unit = 'B'
              @attributes[name].acronym = 'M FREE'
            when "freeMemoryPercent"
              getter = ( =>
                return si.mem().then( (res) ->
                    return Math.round(res.free / res.total * 1000) / 10
                )
              )
              @attributes[name].unit = '%'
              @attributes[name].acronym = 'M FREE%'
            when "processes"
              getter = ( =>
                return si.processes().then( (res) ->
                  return res.all
                )
              )
              @attributes[name].unit = ''
              @attributes[name].acronym = 'PROCS'
            when "memoryRss"
              getter = ( => Promise.resolve(process.memoryUsage().rss) )
              @attributes[name].unit = 'B'
              @attributes[name].acronym = 'RSS'
            when "memoryHeapUsed"
              getter = ( => Promise.resolve(process.memoryUsage().heapUsed) )
              @attributes[name].unit = 'B'
              @attributes[name].acronym = 'HEAP'
            when "memoryHeapTotal"
              getter = ( => Promise.resolve(process.memoryUsage().heapTotal) )
              @attributes[name].unit = 'B'
              @attributes[name].acronym = 'T HEAP'
            when "diskUsagePercent"
              mountPath = attr.path?.toUpperCase() or '/'
              getter = ( =>
                return si.fsSize().then( (res) ->
                  match = (res.filter (i) -> i.mount.toUpperCase() is mountPath)
                  if match.length > 0
                    return Math.round(match[0].use * 10) / 10
                  else
                    return -1
                )
              )
              @attributes[name].unit = '%'
              @attributes[name].acronym = 'DISK%'
            when "temperature"
              getter = ( =>
                return si.cpuTemperature().then( (res) ->
                  return Math.round(res.main * 10) / 10
                )
              )
              @attributes[name].unit = '°C'
              @attributes[name].acronym = 'T'
            when "temperatureF"
              getter = ( =>
                return si.cpuTemperature().then( (res) ->
                  if res.main >= 0
                    return (res.main * 9/5) + 32
                  else
                    return res.main
                )
              )
              @attributes[name].unit = '°F'
              @attributes[name].acronym = 'T'
            when "dbSize"
              path = env.require 'path'
              databaseConfig = framework.config.settings.database
              unless databaseConfig.client is "sqlite3"
                throw new Error("dbSize is only supported for SQLite3")
              filename = path.resolve framework.maindir, '../..', databaseConfig.connection.filename
              getter = ( =>
                return fs.statAsync(filename).then( (stats) ->
                  return  stats.size
                )
              )
              @attributes[name].unit = 'B'
              @attributes[name].acronym = 'DB SZ'
            when "systemUptime"
              os = env.require 'os'
              getter = ( => Promise.resolve(os.uptime()) )
              @attributes[name].unit = 's'
              @attributes[name].acronym = 'OS UP'
            when "pimaticUptime"
              getter = ( => Promise.resolve(process.uptime()) )
              @attributes[name].unit = 's'
              @attributes[name].acronym = 'PROC UP'
            when "wifiSignalLevel"
              networkInterface = attr.networkInterface or 'wlan0'
              getter = ( =>
                return wifiStatus(networkInterface).then( (res) ->
                  return res.signal
                )
              )
              @attributes[name].unit = 'dBm'
              @attributes[name].acronym = 'RSL'
            when "nwThroughputReceived"
              getter = ( =>
                return si.networkStats(networkInterface).then( (res) ->
                  if not res[0]? or res[0].operstate is 'unknown'
                    throw new Error "Network interface is not available. Check interface name"
                  else
                    return res[0].rx_sec * 8
                )
              )
              @attributes[name].unit = 'bps'
              @attributes[name].acronym = 'NET RX'
            when "nwThroughputSent"
              getter = ( =>
                return si.networkStats(networkInterface).then( (res) ->
                  if not res[0]? or res[0].operstate is 'unknown'
                    throw new Error "Network interface is not available. Check interface name"
                  else
                    return res[0].tx_sec * 8
                )
              )
              @attributes[name].unit = 'bps'
              @attributes[name].acronym = 'NET TX'
            else
              throw new Error("Illegal attribute name: #{name} in SystemSensor.")
          if @attributes[name].additionalCB?
            @attributes[name].additionalCB().catch( (error) ->
              env.logger.error "Attribute #{name}:", error.message
            )
          # Create a getter for this attribute
          @_createGetter(name, getter)
          # setup polling
          @_setupPolling(name, attr.interval or 10000, @attributes[name].additionalCB)    
      super()

    destroy: ->
      super()

  # ###Finally
  # Create a instance of SysInfoPlugin
  sysInfoPlugin = new SysinfoPlugin
  # and return it to the framework.
  return sysInfoPlugin