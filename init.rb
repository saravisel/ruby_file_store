#!/usr/bin/env ruby

#### File Store ####
#
# Launch this Ruby file from the command line
# to get started
# 
## Execute this file using 'ruby init.rb' to create the data store 
# and perform CRD operations.
require_relative 'main'

# to initialize the data store 
store = FileStore.new("fresh_works.txt")

# to initialize the data store without the file
data_store = FileStore.new

# it creates a key-value pair with  time-to-live property.
data_store.create("details", {"name"=>"saranya","degree"=> "btech", "color"=>"red"}, 60)

# it creates a key-value pair with no time-to-live property.
store.create("history", {"hometown"=>"salem","school"=>"holy angels","college"=>"sastra"})

# it returns the value of a respective key in json format if key has not expired
# otherwise it will raise an error
data_store.read("details")

# it deletes the respective key from the data store if key has not expired
# otherwise it will raise an error
store.delete("history")


