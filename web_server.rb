require 'socket'
require 'uri'

WEB_ROOT = './public'
CONTENT_TYPE_MAPPING = {
  'html' => 'text/html',
  'txt' => 'text/plain',
  'png' => 'image/png',
  'jpg' => 'image/jpeg'
}

DEFAULT_CONTENT_TYPE = 'application/octet-stream'


def content_type(path)
  ext = File.extname(path).split(".").last
  CONTENT_TYPE_MAPPING.fetch(ext, DEFAULT_CONTENT_TYPE)
end

def requested_file(request_line)
  request_uri = request_line.split(" ")[1]
  path = URI.unescape(URI(request_uri).path)

  clean = []
  parts = path.split('/')

  parts.each do |part|
    # Skip empty or current dir('.')
    next if part.empty? || part == '.'

    part == '..' ? clean.pop : clean << part
  end

  File.join(WEB_ROOT, *clean)
end

server = TCPServer.new('localhost', 2345)

# Waitting
loop do

  # Return a TCPSocket
  socket = server.accept

  # Read the first line of the request
  request_line = socket.gets

  # Log the request to the console for debugging
  STDERR.puts request_line

  path = requested_file(request_line)

  # set index.html as default file of dir
  path = File.join(path, 'index.html') if File.directory?(path)

  if File.exist?(path) && !File.directory?(path)
    File.open(path, "rb") do |file|
      socket.print "HTTP/1.1 200 OK\r\n" +
        "Content-Type: #{content_type(file)}\r\n" +
        "Content-Length: #{file.size}\r\n" +
        "Connection: close\r\n"

        # Blank line
        socket.print "\r\n"

        # Write the content of the file to the socket
        IO.copy_stream(file, socket)
    end
  else
    message = "File not found\n"
    socket.print "HTTP/1.1 404 Not Found\r\n" +
      "Content-Type: text/plain\r\n" +
      "Content-Length: #{message.size}\r\n" +
      "Connection: close\r\n"

      socket.print "\r\n"
      # Response body
      socket.print message
  end

  # Close the socket
  socket.close
end
