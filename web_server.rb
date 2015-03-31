require 'socket'

server = TCPServer.new('localhost', 2345)

# Waitting
loop do

  # Return a TCPSocket
  socket = server.accept

  # Read the first line of the request
  request = socket.gets

  # Log the request to the console for debugging
  STDERR.puts request

  response = "Hello World!\n"

  socket.print "HTTP/1.1 200 OK\r\n" +
               "Content-Type: text/plain\r\n" +
               "Content-Length: #{response.bytesize}\r\n" +
               "Connection: close\r\n"

  # Blank line
  socket.print "\r\n"

  # Response body
  socket.print response

  # Close the socket
  socket.close
end
