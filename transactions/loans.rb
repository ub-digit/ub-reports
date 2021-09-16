module Transactions
  class Loans
    QUERY = "loans"

    def initialize(db, subpath)
      @db = db
      @subpath = subpath
    end

    def run(year)
      fetch(year).map{|row| row.values }
    end

    def hash_init()
      {
        "issue" => 0,
        "return" => 0,
        "onsite_checkout" => 0,
      }
    end

    def fetch(year)
      query = read_query_from_file(QUERY)
      query.gsub!(/%%QUERY_YEAR%%/, year)
      fetch_query(query).to_a
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