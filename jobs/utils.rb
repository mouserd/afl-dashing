def to_friendly_duration(millis)
  x = millis / 1000
  seconds = x % 60
  x /= 60
  minutes = x % 60
  x /= 60
  hours = x % 24

  hours > 0 ? "#{hours}h" : minutes > 0 ? "#{minutes}m #{seconds}s" : "#{seconds}s"
end