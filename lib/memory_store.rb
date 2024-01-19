module MemoryStore
  def mem_connection
    Dalli::Client.new(server, options)
  end

  private

  def server
    'localhost:11211'
  end

  def options
    { namespace: "app_v1" }
  end
end