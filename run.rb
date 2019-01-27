#!/usr/bin/env ruby

#/Applications/Shoes.app/Contents/MacOS/shoes
#/usr/bin/env shoes

Root = File.dirname(__FILE__)

require "#{Root}/lib/life.rb"

Life.start
