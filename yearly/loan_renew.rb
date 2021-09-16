module Yearly
  class LoanRenew
    def initialize(db, subpath)
      @db = db
      @subpath = subpath
    end

    def run_queries(queries, year)
      libraries = {}
      raw_data = fetch_all(queries, year)
      libraries = make_sums(libraries, raw_data[0])
      libraries = make_sums(libraries, raw_data[1])
      totals = make_totals(libraries)
      libraries["totals"] = totals
      libraries
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

    def hash_init()
      {
        "initial" => 0,
        "renewals_total" => 0,
        "renewals_manual" => 0,
        "renewals_auto" => 0,
        "total" => 0
      }
    end

    def make_sums(libraries, libdata)
      libdata.each do |row|
        lib = row["branchcode"]
        libraries[lib] ||= hash_init()
        if(row["auto_renew"] == 1)
          libraries[lib]["renewals_auto"] += row["renewals"]
        else
          libraries[lib]["renewals_manual"] += row["renewals"]
        end
        libraries[lib]["renewals_total"] += row["renewals"]
        libraries[lib]["initial"] += row["Antal"]
        libraries[lib]["total"] += row["renewals"]
        libraries[lib]["total"] += row["Antal"]
      end

      libraries
    end

    def fetch_all(queries, year)
      queries.map do |query_name|
        query = read_query_from_file(query_name)
        query.gsub!(/%%QUERY_YEAR%%/, year)
        fetch_query(query).to_a
      end
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