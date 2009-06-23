## Feedback
## 
## Requires json (sudo gem install json)
## Usage:
## feedback = Feedback.new
## feedback.receive
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
    buffer = ''

    while (!ssl.eof?)
      buffer += ssl.read
    end

    # Need to do something with 'buffer' now.

    ssl.close
    socket.close
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