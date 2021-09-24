module KB
  class Fetch
    def initialize(db, subpath)
      @db = db
      @subpath = subpath
    end

    def run(year)
      data = fetch_main(year)
      subscription_count = fetch_subscriptions()
      set("subscriptions", data["total"], data["acq"], subscription_count, nil)
      pp data
    end

    def fetch_main(year)
      query = read_query_from_file("kb10")
      data = main_stats(query, year)
      set("audiobooks", data["total"], data["acq"], nil, nil)
      set("daisybooks", data["total"], data["acq"], nil, nil)
      set("newspapers", data["total"], data["acq"], 10, nil)
      data
    end

    def fetch_subscriptions()
      query = read_query_from_file("subscriptions")
      data = fetch_query(query, :koha).to_a
      data[0]["antal"]
    end

    def hash_init()
      {
        "written_books" => 0,
        "textbooks" => 0,
        "audiobooks" => 0,
        "daisybooks" => 0,
        "subscriptions" => 0,
        "newspapers" => 0,
        "music_recordings" => 0,
        "film_tv" => 0,
        "microfilm" => 0,
        "images" => 0,
        "manuscripts" => 0,
        "interactive" => 0,
        "other" => 0
      }
    end

    def main_stats(query, year)
      total = hash_init()
      acq = hash_init()
      fetch_query(query).each do |row|
        parse_row(total, acq, year, row)
      end
      {"total" => total, "acq" => acq}
    end

    def parse_row(total, acq, year, row)
      if row["pos06"] == "a" && row["pos07"][/[cdm]/]
        inc("written_books", total, acq, row["year"], year)
        inc("textbooks", total, acq, row["year"], year) if(row["itype"].to_s == "2")
      elsif row["pos06"] == "l"
        inc("audiobooks", total, acq, row["year"], year)
      elsif row["pos06"] == "j"
        inc("music_recordings", total, acq, row["year"], year)
      elsif row["pos06"] == "g"
        inc("film_tv", total, acq, row["year"], year)
      elsif row["itype"] == "17"
        inc("microfilm", total, acq, row["year"], year)
      elsif row["pos06"][/[kef]/]
        inc("images", total, acq, row["year"], year)
      elsif row["pos06"][/[cdt]/]
        inc("manuscripts", total, acq, row["year"], year)
      elsif row["pos06"] == "a" && row["pos07"][/[ab]/]
        inc("manuscripts", total, acq, row["year"], year)
      elsif row["pos06"] == "a" && row["pos07"] == "m" && row["cf8_pos29"] == "1"
        inc("manuscripts", total, acq, row["year"], year)
      elsif row["pos06"] == "a" && row["pos07"] == "m" && row["cf8_pos24_27"][/^t/]
        inc("manuscripts", total, acq, row["year"], year)
      elsif row["pos06"] == "a" && row["pos07"] == "m" && row["cf8_pos24_27"][/^j/]
        inc("manuscripts", total, acq, row["year"], year)
      elsif row["pos06"] == "m"
        inc("interactive", total, acq, row["year"], year)
      elsif row["pos06"][/[opr]/]
        inc("other", total, acq, row["year"], year)
      end
    end
    
    def inc(code, total, acq, acq_year, report_year)
      total[code] += 1
      acq[code] += 1 if(acq_year.to_s == report_year.to_s)
    end

    def set(code, total, acq, total_value, acq_value)
      total[code] = total_value
      acq[code] = acq_value
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

    def fetch_query(query, source = :pg)
      return @db.pg.query(query) if source == :pg
      return @db.mysql.query(query) if source == :koha
    end
  end
end