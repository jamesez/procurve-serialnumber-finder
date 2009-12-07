#!/usr/bin/ruby

# == Synopsis
#
# get-serial-numbers: retrieve serial numbers from a ProCurve switch over SNMP
#
# == Usage
#
# get-serial-numbers [options] switch-name-or-ip-address
#
# -h, --help:
#    show help
#
# --community [name]:
#    use snmp community name (default: public)
#
# --wiki:
#    write out output formatted for confluence
#

require 'getoptlong'
require 'rdoc/usage'

require 'rubygems'
require 'snmp'
include SNMP

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--community', '-c', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--wiki', GetoptLong::NO_ARGUMENT ]
)

community = "public"
wiki = false

opts.each do |opt, arg|
  case opt
    when '--help'
      RDoc::usage
    when '--community'
      community = arg
    when '--wiki'
      wiki = true
  end
end

if ARGV.length != 1
  puts "Missing switch argument (try --help)"
  exit 0
end

switch = ARGV.shift

serialNumbers = ObjectId.new("1.3.6.1.2.1.47.1.1.1.1.11")
modelNames = ObjectId.new("1.3.6.1.2.1.47.1.1.1.1.2")

if wiki
  puts "h5. #{switch}"
  puts "||Component||Serial Number||"
else
  puts "Component\t\tSerial Number"
end

Manager.open(:Host => switch, :Community => community) do |manager|
  response = manager.walk([serialNumbers, modelNames]) do |serialNumber, modelName|
    next if serialNumber.value.strip == ""
    if wiki
      puts "|#{modelName.value.strip}|#{serialNumber.value.strip}|"
    else
      puts "#{modelName.value.strip}\t\t#{serialNumber.value.strip}"
    end
  end
end
