#!/usr/bin/env ruby

require 'pp'
require 'json'
require_relative 'illout_sv'
require_relative 'illout_for'
require_relative 'homeloan'
require_relative 'illin'

module Yearly
  class Fetch
    def initialize(db, subpath)
      @db = db
      @illout_sv = ILLOutSv.new(@db, subpath)
      @illout_for = ILLOutFor.new(@db, subpath)
      @homeloan = Homeloan.new(@db, subpath)
      @illin = ILLIn.new(@db, subpath)
    end

    def fetch_all(year)
      {
        "year" => year,
        "illout_sv" => @illout_sv.run(year),
        "illout_for" => @illout_for.run(year),
        "homeloan" => @homeloan.run(year),
        "illin" => @illin.run(year)
      }
    end

    def output_json(year)
      fetch_all(year).to_json
    end
  end
end
