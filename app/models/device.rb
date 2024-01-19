class Device
  extend MemoryStore
  
  attr_accessor :uuid, :readings

  def self.find(uuid)
    if mem_connection.get(uuid)
      Device.new(uuid: uuid, readings: mem_connection.get(uuid))
    else
      nil
    end
  end

  def self.create(uuid:, readings: nil)
    readings = [readings] if readings.is_a? Hash
    mem_connection.set(uuid, readings)
    Device.new(uuid: uuid, readings: mem_connection.get(uuid))
  end
  
  def initialize(uuid:, readings: nil)
    @uuid = uuid
    @readings = readings
  end

  def update(reading)
    if reading.is_a? Array
      readings = self.readings + reading
    else
      self.readings << reading
      readings = self.readings
    end

    mem_connection.set(uuid, readings)
  end

  def latest_timestamp
    return unless readings
    
    readings
      .map { |r| r[:timestamp] }
      .max
  end

  def cumulative_count
    return unless readings

    readings.inject(0) { |sum, reading| sum + reading[:count] }  
  end

  private

  def mem_connection
    self.class.mem_connection
  end
end