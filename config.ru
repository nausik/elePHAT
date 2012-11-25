require 'sinatra'
require 'data_mapper'
require 'dm-migrations'
require 'rbbcode'
require 'dm-tags'
require 'digest/md5'
require 'warden'

require_relative 'elePHAT'
require_relative 'Models/Post'
require_relative 'Models/User'
require_relative 'DataMapper'

Logic.run!