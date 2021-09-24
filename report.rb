require_relative 'common/db'
require_relative 'yearly/report'
require_relative 'transactions/report'
require_relative 'acquisitions/report'
require_relative 'kb/report'

class Report
  def self.run_all(year)
    db = DB.new
    yearly(db, year)
    transactions(db, year)
    acquisitions(db, year)
    kb(db, year)
  end

  def self.run_one(year, report_name)
    db = DB.new
    if report_name == "yearly"
      yearly(db, year)
    elsif report_name == "transactions"
      transactions(db, year)
    elsif report_name == "acquisitions"
      acquisitions(db, year)
    elsif report_name == "kb"
      kb(db, year)
    else
      puts "Unknown report name: #{report_name}"
    end
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

  def self.kb(db, year)
    puts "Creating kb report [#{year}]..."
    KB::Report.run(db, "kb", "output/kb-#{year}.xlsx", year)
  end
end

if __FILE__ == $0
  if ARGV[0] && ARGV[0][/^\d\d\d\d$/]
    if ARGV[1]
      Report.run_one(ARGV[0], ARGV[1])
    else
      Report.run_all(ARGV[0])
    end
  else
    puts "Usage: #{$0} year [report-name]"
    exit
  end
end