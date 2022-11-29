require 'mysql2'
require 'pg'

class DB
  attr_reader :mysql, :pg

  def initialize
    read_env(".env.local")
    @mysql = Mysql2::Client.new(:host => ENV["KOHA_MY_DB_HOST"], :username => ENV["KOHA_MY_DB_USER"], 
                                :password => ENV["KOHA_MY_DB_PASS"], :database => ENV["KOHA_MY_DB_NAME"])
    @mysql.query("SET NAMES utf8")
    # @pg = PG.connect(:host => ENV["KOHA_PG_DB_HOST"], :user => ENV["KOHA_PG_DB_USER"], 
    #                  :password => ENV["KOHA_PG_DB_PASS"], :dbname => ENV["KOHA_PG_DB_NAME"])
  end

  def read_env(envfile)
    return if !File.exists?(envfile)
    File.open(envfile, "rb") do |f|
      f.each_line do |line|
        next if line[/^\s*#/]
        key,value = line.chomp!.split(/=/,2).map{|x| x.strip}
        next if key.nil?
        ENV[key] = value
      end
    end
  end
end