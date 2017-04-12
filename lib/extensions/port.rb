require 'socket'
require 'openssl'

def is_ssl_enabled?(tcp_socket)
  ctx = OpenSSL::SSL::SSLContext.new
  ctx.set_params({ :options=>OpenSSL::SSL::OP_ALL })
  ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
  enabled = true

  OpenSSL::SSL::SSLSocket.new(tcp_socket, ctx).tap do |socket|
    begin
      socket.sync_close = true
      socket.connect_nonblock
    rescue IO::WaitReadable
      if IO.select([socket], nil, nil, 1)
        retry
      else
        enabled = false
      end
    rescue IO::WaitWritable
      if IO.select([socket], nil, nil, 1)
        retry
      else
        enabled = false
      end
    rescue OpenSSL::SSL::SSLError
      enabled = false
    end

    return enabled
  end
end

def connect_to_port(port)
  begin
    TCPSocket.new('0.0.0.0', port)
  rescue StandardError # Errno::ECONNREFUSED mainly but covering for timeouts
    nil
  end
end

def get_port_state(port)
  state = { :open => false,
            :ssl => "unknown" }

  tcp_socket = connect_to_port(port)

  return state unless tcp_socket # couldn't connect, can't figure anything out

  state[:open] = true
  state[:ssl] = is_ssl_enabled?(tcp_socket)

  tcp_socket.close

  state
end

def combine_port_states(states)
  states.reduce({}) do |old_state, state|
    old_state[:open] ||= state[:open]
    old_state[:ssl] ||= state[:ssl]

    old_state[:open] &&= state[:open]
    old_state[:ssl] &&= state[:open]

    old_state
  end
end

# TODO(ploubser): Write custom compare function
#compare_fn(:port) do |name, expected, actual|
#end

create_resource(:port) do |port|
  resource = Puppet::Resource.new('ssl', port.to_s)
  state = {}

  if port =~ /^(\d+)-(\d+)$/
    port_states = []
    ports = ($1.to_i..$2.to_i).to_a
    threads = (0...10).map do # god help us all
      Thread.new do
        while p = ports.pop
          port_states << get_port_state(p)
        end
      end
    end
    threads.map(&:join)
    state = combine_port_states(port_states)
  elsif port =~ /^(\d+)$/
    state = get_port_state(port)
  else
    state = { :open => 'unknown',
              :ssl => 'unknown' }
  end

  # add the state keys to the resource
  state.each do |key, val|
    resource[key] = val
  end

  resource
end
