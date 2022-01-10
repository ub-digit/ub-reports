require_relative 'koha_avs'

module Acquisitions
  class Fetch
    QUERY="acq_pg"

    def initialize(db, subpath)
      @db = db
      @subpath = subpath
      @koha = KohaAVs.new(db)
    end

    def run(year)
      @year = year
      @short_year = year.to_s[-2..(year.size+1)]
      # data = fetch_cached()
      data = fetch()
      parse_data(data)
    end

    def parse_data(input)
      libs = {}
      kurs = {}
      sigel = {}
      total = {
        "bibs" => 0,
        "items" => 0,
        "bibs_kurs" => 0,
        "items_kurs" => 0
      }
      libs_total = {}

      input.each do |row|
        acq_type = row["substring"].downcase
        next if acq_type != "k" && acq_type != "f"
        key = top_level_key(row)
        sig = @koha.sigel[row["homebranch"]] || "UNKNOWN SIGEL"
        libs[key] ||= {}
        libs_total[key] ||= {"bibs" => 0, "items" => 0}
        sigel[sig] ||= {
          "bibs_k" => 0, 
          "items_k" => 0,
          "bibs_f" => 0,
          "items_f" => 0,
          "bibs_kurs_k" => 0, 
          "items_kurs_k" => 0,
          "bibs_kurs_f" => 0,
          "items_kurs_f" => 0,
          "bibs_kurs" => 0,
          "items_kurs" => 0,
        }
        itemtype = @koha.itemtype[row["itype"]] || "UNKNOWN ITEMTYPE"
        loc = @koha.loc[row["location"]] || "UNKNOWN LOC"
        # if loc == "UNKNOWN LOC"
        #   puts "# #{row.inspect}"
        # end
        is_kurs = is_kurs?(itemtype, loc)
        if(is_kurs) 
          kurs[[itemtype, loc]] ||= { "itemtype" => itemtype, "loc" => loc, "bibs" => 0, "items" => 0 }
          kurs[[itemtype, loc]]["bibs"] += 1
          kurs[[itemtype, loc]]["items"] += row["count"].to_i
        end
        libs[key][itemtype] ||= {"bibs" => 0, "items" => 0, "locs" => {}}
        libs[key][itemtype]["bibs"] += 1
        libs[key][itemtype]["items"] += row["count"].to_i
        libs[key][itemtype]["locs"][loc] ||= { "bibs" => 0, "items" => 0, "is_kurs" => is_kurs }
        libs[key][itemtype]["locs"][loc]["bibs"] += 1
        libs[key][itemtype]["locs"][loc]["items"] += row["count"].to_i
        libs_total[key]["bibs"] += 1
        libs_total[key]["items"] += row["count"].to_i

        begin
        sigel[sig]["bibs_#{acq_type}"] += 1
        rescue
          STDERR.puts [sig, acq_type, row].inspect
        end
        sigel[sig]["items_#{acq_type}"] += row["count"].to_i
        total["bibs"] += 1
        total["items"] += row["count"].to_i
        if(is_kurs)
          sigel[sig]["bibs_kurs_#{acq_type}"] += 1
          sigel[sig]["items_kurs_#{acq_type}"] += row["count"].to_i
          sigel[sig]["bibs_kurs"] += 1
          sigel[sig]["items_kurs"] += row["count"].to_i
          total["bibs_kurs"] += 1
          total["items_kurs"] += row["count"].to_i
          end
      end
      {"year" => @year, "library" => libs, "kursbok" => kurs, 
      "sigel" => sigel, "total" => total, "library_total" => libs_total}
    end

    def is_kurs?(itemtype, loc)
      !!loc[/KURS/] || itemtype == "Kursbok"
    end

    def top_level_key(row)
      sigel = @koha.sigel[row["homebranch"]] || "UNKNOWN SIGEL"
      acq_type = row["substring"].upcase
      "#{sigel}#{@short_year}_#{acq_type}"
    end

    def fetch()
      query = read_query_from_file(QUERY)
      query.gsub!(/%%QUERY_YEAR%%/, @year)
      query.gsub!(/%%QUERY_YEAR_SHORT%%/, @short_year)
      fetch_query(query).to_a
    end
    
    def read_query_from_file(query_name)
      File.open("#{@subpath}/queries/#{query_name}.sql", "r:utf-8") do |f|
        return f.read
      end
    end

    def fetch_cached()
      # File.open("temp/cached-2020.json", "rb") { |f| JSON.parse(f.read) }
      # File.open("temp/temp.json", "rb") { |f| JSON.parse(f.read) }
    end

    def fetch_query(query)
      @db.pg.query(query)
    end
  end
end
