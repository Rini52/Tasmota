#
# Matter_Plugin_Sensor.be - implements the behavior for a generic Sensor
#
# Copyright (C) 2023  Stephan Hadinger & Theo Arends
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# Matter plug-in for core behavior

# dummy declaration for solidification
class Matter_Plugin_Device end

#@ solidify:Matter_Plugin_Sensor,weak

class Matter_Plugin_Sensor : Matter_Plugin_Device
  var tasmota_sensor_filter                         # Rule-type filter to the value, like "ESP32#Temperature"
  var tasmota_sensor_matcher                        # Actual matcher object
  var shadow_value                                  # Last known value

  #############################################################
  # Constructor
  def init(device, endpoint, arguments)
    super(self).init(device, endpoint, arguments)
    self.tasmota_sensor_filter = arguments.find('filter')
    if self.tasmota_sensor_filter
      self.tasmota_sensor_matcher = tasmota.Rule_Matcher.parse(self.tasmota_sensor_filter)
    end
  end

  #############################################################
  # parse sensor
  #
  # The device calls regularly `tasmota.read_sensors()` and converts
  # it to json.
  def parse_sensors(payload)
    if self.tasmota_sensor_matcher
      var val = self.pre_value(real(self.tasmota_sensor_matcher.match(payload)))
      if val != nil
        if val != self.shadow_value
          self.valued_changed(val)
        end
        self.shadow_value = val
      end
    end
  end

  #############################################################
  # Called when the value changed compared to shadow value
  #
  # This must be overriden.
  # This is where you call `self.attribute_updated(nil, <cluster>, <attribute>)`
  def valued_changed(val)
    # self.attribute_updated(nil, 0x0402, 0x0000)
  end

  #############################################################
  # Pre-process value
  #
  # This must be overriden.
  # This allows to convert the raw sensor value to the target one, typically int
  def pre_value(val)
    return val
  end

  #############################################################
  # to_json_parameters
  #
  # To be overriden.
  # returns a json sub-string to add after endpoint and type name
  def to_json_parameters(s)
    import string
    s += string.format(',"filter":"%s"', self.tasmota_sensor_filter)
    return s
  end

end
matter.Plugin_Sensor = Matter_Plugin_Sensor
