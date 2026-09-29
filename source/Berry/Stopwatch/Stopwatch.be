# @name {{APP_NAME}}
# @description Select starts or pauses; three paced presses reset.
class Stopwatch
  var running
  var started
  var elapsed
  var selectCount
  var lastSelect
  var label
  var labelX
  var color

  def init()
    self.running = false
    self.started = 0
    self.elapsed = store.get("elapsedMs", 0)
    self.selectCount = 0
    self.lastSelect = 0
    self.label = "0:00.00"
    self.labelX = 0
    self.color = 0xFFAA00
  end

  def setup()
    mqtt.subscribe("{{RESET_TOPIC}}", def (topic, payload) self.reset() end)
    mqtt.subscribe("{{CONTROL_TOPIC}}", def (topic, payload) self.control(payload) end)
    self.update_display(self.elapsed, 0xFFAA00)
  end

  def update_display(elapsed, color)
    var total = int(elapsed / 1000)
    var minutes = int(total / 60)
    var seconds = total % 60
    var hundredths = int((elapsed % 1000) / 10)
    var secondsText = seconds < 10 ? "0" + str(seconds) : str(seconds)
    var hundredthsText = hundredths < 10 ? "0" + str(hundredths) : str(hundredths)
    self.label = str(minutes) + ":" + secondsText + "." + hundredthsText
    self.labelX = (width() - text_ink_width(self.label)) / 2
    self.color = color
  end

  def start()
    if !self.running
      self.started = now_ms()
      self.running = true
      self.update_display(self.elapsed, 0x00FF00)
      mqtt.publish("{{STATE_TOPIC}}", "running")
    end
  end

  def pause()
    if self.running
      self.elapsed = self.elapsed + now_ms() - self.started
      self.running = false
      store.set("elapsedMs", self.elapsed)
      self.update_display(self.elapsed, 0xFFAA00)
      mqtt.publish("{{STATE_TOPIC}}", "paused")
    end
  end

  def toggle()
    if self.running
      self.pause()
    else
      self.start()
    end
  end

  def reset()
    self.running = false
    self.started = 0
    self.elapsed = 0
    self.selectCount = 0
    self.lastSelect = 0
    store.set("elapsedMs", 0)
    self.update_display(0, 0xFFAA00)
    mqtt.publish("{{STATE_TOPIC}}", "reset")
  end

  def restart()
    self.elapsed = 0
    self.selectCount = 0
    self.lastSelect = 0
    store.set("elapsedMs", 0)
    self.running = false
    self.start()
  end

  def control(command)
    if command == "start"
      self.start()
    elif command == "pause"
      self.pause()
    elif command == "toggle"
      self.toggle()
    elif command == "reset"
      self.reset()
    elif command == "restart"
      self.restart()
    end
  end

  def on_button(btn)
    if btn == "select"
      var pressed = now_ms()
      var gap = pressed - self.lastSelect
      if self.lastSelect > 0 && gap >= 350 && gap <= 1200
        self.selectCount = self.selectCount + 1
      else
        self.selectCount = 1
      end
      self.lastSelect = pressed

      if self.selectCount >= 3
        self.reset()
        return
      end

      self.toggle()
    end
  end

  def draw()
    if self.running
      self.update_display(self.elapsed + now_ms() - self.started, 0x00FF00)
    end
    clear()
    text(self.labelX, 6, self.label, self.color)
  end

  def duration()
    return 60000
  end
end

return Stopwatch()
