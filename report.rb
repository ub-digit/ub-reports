require_relative 'common/db'
require_relative 'yearly/report'
require_relative 'transactions/report'
require_relative 'acquisitions/report'

class Report
  def self.run_all(year)
    db = DB.new
    yearly(db, year)
    transactions(db, year)
    acquisitions(db, year)
  end

  def self.yearly(db, year)
    puts "Creating yearly report [#{year}]..."
    Yearly::Report.run(db, "yearly", "output/yearly-#{year}.xlsx", year)
  end

  def self.transactions(db, year)
    puts "Creating transactions report [#{year}]..."
    Transactions::Report.run(db, "transactions", "output/transactions-#{year}.xlsx", year)
  end

  def self.acquisitions(db, year)
    puts "Creating acquistions report [#{year}]..."
    Acquisitions::Report.run(db, "acquisitions", "output/acquisitions-#{year}.xlsx", year)
  end
end

if __FILE__ == $0
  if ARGV[0] && ARGV[0][/^\d\d\d\d$/]
    Report.run_all(ARGV[0])
  else
    puts "Usage: #{$0} year"
    exit
  end
end