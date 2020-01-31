#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require 'psych'
require 'json'
require 'active_support/core_ext/numeric/time.rb'
require 'fileutils'


class FileStore  
  def initialize(file=nil)
    # locate file in APP_ROOT
    file_name = file.blank? ? 'storage.txt' : file
    # @filepath = File.join(File.expand_path(File.dirname(__FILE__)), file_name)
    @filepath = File.expand_path(file_name)
    if File.exists?(@filepath)
      # confirm that it is readable and writable
      if !File.readable?(@filepath)
        abort("File exists but it is not readable")
      end
      if !File.writable?(@filepath)
        abort("File exists but it is not writable")
      end
    end
    # creating a new file in APP_ROOT
    @file = File.open(@filepath, "a+")
    @file_content = @file.read
    @hash = eval(@file_content.gsub(':', '=>'))
    @hash = {} if @hash.nil?
    # ensure that file is present after create
    if !File.exists?(@filepath)
      abort("File does not exist and could not be created.")
    end
  end

  # To store the data
  def data_store
    File.open(@filepath, 'w') do |file|
      file << JSON.dump(@hash)
    end
  end

  # To create the key
  def create(key, value, expiration_time=0)
    # File size should be less thaan 1 GB
    if @file.size > (1024*1024*1024)
      abort("Memory Limit exceeded")
    # Key cannot be created if key already presents
    elsif @hash.key?(key)
      abort("Key already present in the Data Store")      
    else
      if valid_key?(key) && valid_json?(value)
        expire_time = expiration_time > 0 ? [value, Time.now() + expiration_time] : [value, expiration_time]
        @hash[key.downcase] = expire_time
        data_store
        puts "data created"
      end
    end
  end

  # To access the key
  def read(key)
    # to check key value pair
    check_key_expired?(key)
    if @hash.key?(key)
      # to read data from the file and assign to hash
      puts @hash[key]
      puts "read the data"
    else
      abort("Key is not present in the Data Store")
    end
  end

  # To delete the key
  def delete(key)
    check_key_expired?(key)
    if @hash.key?(key)
      @hash.delete(key)
      data_store
      puts "data deleted"
    else
      abort("Key is not present in the Data Store")
    end
  end

  # To check key has expired 
  def check_key_expired?(key)
    if @hash.key?(key)
      if @hash[key][1] != 0 && Time.now > Time.parse(@hash[key][1].to_s.gsub('=>',':'))
        @hash.delete(key)
        data_store
        abort("Key has been expired could not read/delete")
      end
    else
      abort("Key is not present in the Data Store")
    end
  end

  # validation for key
  def valid_key?(key)
    if key.is_a? String
      return true
    elsif key.size <= 32
      abort("Key size should be less than or equal to 32 chars")
      return false
    else
      abort("Please enter Key in String Format. ")
      return false
    end
  end

  # validation for value
  def valid_json?(json)
    begin
      json_value = JSON.parse(json.to_json)
      if json_value.size <= (16*1024)
        return true
      else
        abort("JSON size should less than 16KB")
        return false
      end
    rescue JSON::ParserError => e
      abort("Value should be in JSON Format")
      return false
    end
  end

end