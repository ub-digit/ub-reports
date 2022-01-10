require 'json'
require 'open-uri'
require 'uri'

module Yearly
  class ILLIn
    SIGEL_URL="https://bibdb.libris.kb.se/api/lib?level=brief&sigel="

    def initialize(db, subpath)
      @db = db
      @subpath = subpath
      read_sigel_cache()
    end

    def run(year)
      fetch(year)
    end

    def fetch(year)
      query = read_query_from_file("illin")
      query.gsub!(/%%QUERY_YEAR%%/, year)
      data = fetch_query(query)
      unissued_query = read_query_from_file("illin-unissued")
      unissued_query.gsub!(/%%QUERY_YEAR%%/, year)
      unissued_data = fetch_query(unissued_query)
      libraries = make_stats(data)
      unissued = make_unissued_stats(unissued_data)
      totals = make_totals(libraries)
      libraries["totals"] = totals
      libraries["unissued"] = unissued
      libraries
    end

    def hash_init()
      {
        "initial_sv" => 0,
        "initial_for" => 0,
        "renewals" => 0,
        "total" => 0
      }
    end

    def make_stats(data)
      libraries = {}
      data.each do |row|
        lib = row["branch"]
        next if lib.nil? || lib.empty?
        libraries[lib] ||= hash_init()
        if row["type"] == "issue"
          if get_country_for_sigel(row["sigel"], row["itemnumber"]) == "se"
            libraries[lib]["initial_sv"] += 1
          else
            libraries[lib]["initial_for"] += 1
          end
          libraries[lib]["total"] += 1
        end
        if row["type"] == "renew"
          libraries[lib]["renewals"] += 1
        end
      end
      libraries
    end

    def make_unissued_stats(data)
      unissued = {"se" => 0, "for" => 0}
      data.each do |row|
        if get_country_for_sigel(row["sigel"], row["itemnumber"]) == "se"
          unissued["se"] += 1
        else
          unissued["for"] += 1
        end
      end
      unissued
    end

    def make_totals(libraries)
      totals = hash_init()
      libraries.keys.each do |lib|
        totals.keys.each do |total_key|
          totals[total_key] += libraries[lib][total_key]
        end
      end
      totals
    end

    def write_sigel_cache()
      File.open("#{@subpath}/data/sigel_cache.json", "wb") do |f|
        f.write(JSON.pretty_generate(@sigel))
      end
    end

    def read_sigel_cache()
      @sigel = JSON.parse(File.read("#{@subpath}/data/sigel_cache.json"))
    end

    def get_country_for_sigel(sigel, itemnumber)
      # Special case where sigel is missing. Distribute roughly equal between se and non-se
      if(!sigel || sigel =~ /^\d\d\d\d\d\d$/)
        return (itemnumber.to_i & 1) ? "se" : "other"
      end
      
      if(@sigel[sigel])
        return @sigel[sigel]
      else
        return fetch_sigel_country(sigel)
      end
    end

    def fetch_sigel_country(sigel)
      encoded_sigel = URI.escape(sigel)
      open(SIGEL_URL + encoded_sigel) do |u|
        json = JSON.parse(u.read)
        if !json["query"]["operation"][/; dump/] && json["libraries"].length > 0
          @sigel[sigel] = json["libraries"][0]["country_code"]
        else
          @sigel[sigel] = "unknown"
        end
      end
      write_sigel_cache()
      @sigel[sigel]
    end

    def read_query_from_file(query_name)
      File.open("#{@subpath}/queries/#{query_name}.sql", "r:utf-8") do |f|
        return f.read
      end
    end

    def fetch_query(query)
      @db.mysql.query(query)
    end
  end
end
