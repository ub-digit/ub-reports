module KB
  class Fetch
    def initialize(db, subpath)
      @db = db
      @subpath = subpath
    end

    def run(year)
      kb10 = fetch_kb10(year)
      kb11 = fetch_kb11()
      kb12 = fetch_kb12()
      kb14 = fetch_kb14(year)
      kb19 = fetch_kb19(year)
      {
        "kb10" => kb10,
        "kb11" => kb11,
        "kb12" => kb12,
        "kb14" => kb14,
        "kb19" => kb19,
      }
    end
    
    def fetch_kb10(year)
      query = read_query_from_file("kb10")
      data = main_stats(query, year)
      set_kb10("audiobooks", data["total"], data["acq"], nil, nil)
      set_kb10("daisybooks", data["total"], data["acq"], nil, nil)
      set_kb10("newspapers", data["total"], data["acq"], 10, nil)
      subscription_count = fetch_subscriptions()
      set_kb10("subscriptions", data["total"], data["acq"], subscription_count, nil)
      data
    end

    def fetch_subscriptions()
      query = read_query_from_file("subscriptions")
      data = fetch_query(query).to_a
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
        parse_kb10_row(total, acq, year, row)
      end
      {"total" => total, "acq" => acq}
    end

    def parse_kb10_row(total, acq, year, row)
      if row["pos06"] == "a" && row["pos07"][/[cdm]/]
        inc_kb10("written_books", total, acq, row["year"], year)
        inc_kb10("textbooks", total, acq, row["year"], year) if(row["itype"].to_s == "2")
      elsif row["pos06"] == "l"
        inc_kb10("audiobooks", total, acq, row["year"], year)
      elsif row["pos06"] == "j"
        inc_kb10("music_recordings", total, acq, row["year"], year)
      elsif row["pos06"] == "g"
        inc_kb10("film_tv", total, acq, row["year"], year)
      elsif row["itype"] == "17"
        inc_kb10("microfilm", total, acq, row["year"], year)
      elsif row["pos06"][/[kef]/]
        inc_kb10("images", total, acq, row["year"], year)
      elsif row["pos06"][/[cdt]/]
        inc_kb10("manuscripts", total, acq, row["year"], year)
      elsif row["pos06"] == "a" && row["pos07"][/[ab]/]
        inc_kb10("manuscripts", total, acq, row["year"], year)
      elsif row["pos06"] == "a" && row["pos07"] == "m" && row["cf8_pos29"] == "1"
        inc_kb10("manuscripts", total, acq, row["year"], year)
      elsif row["pos06"] == "a" && row["pos07"] == "m" && row["cf8_pos24_27"][/^t/]
        inc_kb10("manuscripts", total, acq, row["year"], year)
      elsif row["pos06"] == "a" && row["pos07"] == "m" && row["cf8_pos24_27"][/^j/]
        inc_kb10("manuscripts", total, acq, row["year"], year)
      elsif row["pos06"] == "m"
        inc_kb10("interactive", total, acq, row["year"], year)
      elsif row["pos06"][/[opr]/]
        inc_kb10("other", total, acq, row["year"], year)
      end
    end
    
    def inc_kb10(code, total, acq, acq_year, report_year)
      total[code] += 1
      acq[code] += 1 if(acq_year.to_s == report_year.to_s)
    end

    def set_kb10(code, total, acq, total_value, acq_value)
      total[code] = total_value
      acq[code] = acq_value
    end

    def fetch_kb11()
      sab_data = quick_fetch("kb11_sab")
      dewey_data = quick_fetch("kb11_dewey")
      sab_data[0]["antal"].to_i + dewey_data[0]["antal"].to_i
    end

    def fetch_kb12()
      paper_data = quick_fetch("kb12_paper")[0]
      elec_data = quick_fetch("kb12_elec")[0]
      {
        "paper" => {
          "svenska" => paper_data["svenska"],
          "minoritet" => paper_data["minoritet"],
          "ovrigt" => paper_data["ovrigt"]
        },
        "elec" => {
          "svenska" => elec_data["svenska"],
          "minoritet" => elec_data["minoritet"],
          "ovrigt" => elec_data["ovrigt"]
        }
      }
    end

    def fetch_kb14(year)
      query = read_query_from_file("kb14")
      query.gsub!(/%%QUERY_YEAR%%/, year)

      issues = hash_init()
      renews = hash_init()
      fetch_query(query).each do |row|
        parse_kb14_row(issues, renews, row)
      end
      set_kb10("audiobooks", issues, renews, nil, nil)
      set_kb10("daisybooks", issues, renews, nil, nil)
      set_kb10("newspapers", issues, renews, nil, nil)

      {
        "issues" => issues,
        "renews" => renews
      }
    end

    def parse_kb14_row(issues, renews, row)
      if row["pos06"] == "a" && row["pos07"][/[cdm]/]
        inc_kb14("written_books", issues, renews, row["type"])
        inc_kb14("textbooks", issues, renews, row["type"]) if(row["itemtype"].to_s == "2")
      elsif row["pos06"] == "a" && row["pos07"] == "s"
        inc_kb14("subscriptions", issues, renews, row["type"])
      elsif row["pos06"] == "l"
        inc_kb14("audiobooks", issues, renews, row["type"])
      elsif row["pos06"] == "j"
        inc_kb14("music_recordings", issues, renews, row["type"])
      elsif row["pos06"] == "g"
        inc_kb14("film_tv", issues, renews, row["type"])
      elsif row["itemtype"] == "17"
        inc_kb14("microfilm", issues, renews, row["type"])
      elsif row["pos06"][/[kef]/]
        inc_kb14("images", issues, renews, row["type"])
      elsif row["pos06"][/[cdt]/]
        inc_kb14("manuscripts", issues, renews, row["type"])
      elsif row["pos06"] == "a" && row["pos07"][/[ab]/]
        inc_kb14("manuscripts", issues, renews, row["type"])
      elsif row["pos06"] == "a" && row["pos07"] == "m" && row["cf8_pos29"] == "1"
        inc_kb14("manuscripts", issues, renews, row["type"])
      elsif row["pos06"] == "a" && row["pos07"] == "m" && row["cf8_pos24_27"][/^t/]
        inc_kb14("manuscripts", issues, renews, row["type"])
      elsif row["pos06"] == "a" && row["pos07"] == "m" && row["cf8_pos24_27"][/^j/]
        inc_kb14("manuscripts", issues, renews, row["type"])
      elsif row["pos06"] == "m"
        inc_kb14("interactive", issues, renews, row["type"])
      elsif row["pos06"][/[opr]/]
        inc_kb14("other", issues, renews, row["type"])
      end
    end

    def inc_kb14(code, issues, renews, type)
      if type == "renew"
        renews[code] += 1
      else
        issues[code] += 1
      end
    end

    def set_kb14(code, issues, renews, issues_value, renews_value)
      issues[code] = issues_value
      renews[code] = renews_value
    end

    def fetch_kb19(year)
      query = read_query_from_file("kb19")
      query.gsub!(/%%QUERY_YEAR%%/, year)

      seen_borrowers = {}
      data = { "male" => 0, "female" => 0, "other" => 0, "lowage" => 0 }
      fetch_query(query).each do |row|
        next if seen_borrowers[row["borrowernumber"]]
        seen_borrowers[row["borrowernumber"]] = true
        pnr = row["attribute"]
        next if pnr.nil?
        pnr_gender = gender(pnr)
        data["male"] += 1 if pnr_gender == :male
        data["female"] += 1 if pnr_gender == :female
        data["other"] += 1 if pnr_gender == :other
        data["lowage"] += 1 if lowage?(pnr, year)
      end
      data
    end

    def gender(pnr)
      return :other if pnr.length != 10
      return :other if pnr[8] !~ /^\d$/
      return :male if pnr[8].to_i % 2 == 1
      return :female
    end

    def lowage?(pnr, year)
      lowage_thres = 18
      return false if pnr.length != 10
      return false if pnr[0..1] !~ /^\d\d$/
      yearstart2 = ((year.to_i - lowage_thres).to_s)[/\d\d(\d\d)/,1]
      return false if yearstart2.nil?
      yearend2 = (year.to_i.to_s)[/\d\d(\d\d)/,1]
      return false if yearend2.nil?
      pnryear = pnr[0..1].to_i
      return true if pnryear >= yearstart2.to_i && pnryear <= yearend2.to_i
      return false
    end

    def quick_fetch(query_name)
      query = read_query_from_file(query_name)
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
      @db.mysql.query(query)
    end
  end
end