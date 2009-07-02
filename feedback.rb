## Feedback
## 
## Requires json (sudo gem install json)
## Usage:
## devices = Feedback.receive
##
## Copyright (c) 2009 Jonathan George (jonathan@jdg.net)
##
## MIT Licensed

#require 'rubygems'

require 'socket'
require 'openssl'
require 'json'

class Feedback
  HOST = 'feedback.sandbox.push.apple.com'
  PATH = '/'
  PORT = 2196
  CERT = File.read(File.join(RAILS_ROOT, "config", "apple_push_notification.pem")) if File.exists?(File.join(RAILS_ROOT, "config", "apple_push_notification.pem"))
  PASSPHRASE = ''
  USERAGENT = 'Ruby/Feedback.rb'

  attr_accessor :sound, :badge, :alert, :app_data
  attr_reader :device_token

  def initialize

  end

  def self.receive
    socket, ssl = ssl_connection

    devices = []

    while data = socket.read(76)
      next if data.size < 76
      timestamp, token_length, device_token = data.unpack('N1n1H140')
      devices << { :timestamp => timestamp, :device_token => device_token}
    end

    puts "Devices: " if devices.any?
    devices.each do |device|
      puts "\t#{device[:device_token]}"
    end

    ssl.close
    socket.close
    return devices
  rescue SocketError => error
    raise "Error while receieving feedback: #{error}"

  end

  def self.ssl_connection
    ctx = OpenSSL::SSL::SSLContext.new
    ctx.key = OpenSSL::PKey::RSA.new(CERT, PASSPHRASE)
    ctx.cert = OpenSSL::X509::Certificate.new(CERT)

    sock = TCPSocket.new(HOST, PORT)
    ssl = OpenSSL::SSL::SSLSocket.new(sock, ctx)
    ssl.sync = true
    ssl.connect

    return sock, ssl
  end
end