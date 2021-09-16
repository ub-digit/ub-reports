#!/usr/bin/env ruby

require_relative '../common/excel'
require_relative 'performer'
require_relative 'loans'

module Transactions
  class Report
    def self.run(db, subpath, output_file, year)
      loans = Loans.new(db, subpath)
      loan_data = loans.run(year)
      performer = Performer.new(db, subpath)
      performer_data = performer.run(year)
      report = Report.new(loan_data, performer_data)
      report.save_xlsx(output_file)
    end

    def initialize(loan_data, performer_data)
      @xl = Excel.new()
      @loan_data_size = loan_data.length
      @performer_data_size = performer_data.length
      @xl.add_sheet("Lån", 25, 25)
      @xl.add_sheet("Utförare", 10, performer_data.length+2)
      @xl.add_sheet("Lånedata", 7, loan_data.length+1)

      @xl.set_current_sheet("Lånedata")
      loans_header()
      fill_loans_datasheet(loan_data)
      @xl.set_current_sheet("Utförare")
      performers_header()
      performers_list(performer_data)
      performers_footer()
      add_tables()
      add_pivots()
    end

    def performers_list(data)
      data.each.with_index do |row,i|
        @xl.cell_list("A#{i+2}", [row["performer"], row["issue"], row["onsite_checkout"], row["return"], row["sum"]])
      end
    end

    def performers_header()
      @xl.cell_list("A1", ["Inloggad användare", "Utlån", "Utlån på plats", "Återlämning", "Summa"])
    end

    def performers_footer()
      above = @performer_data_size
      @xl.cell_list("A#{above+2}", ["Summa", "=SUM(B2:B#{above})", "=SUM(C2:C#{above})", "=SUM(D2:D#{above})", "=SUM(E2:E#{above})"])
    end

    def fill_loans_datasheet(data)
      data.each.with_index do |row,i|
        @xl.cell_list([0, i+1], row)
      end
    end

    def loans_header()
      @xl.cell_list("A1", ["DATUM", "BIBL", "KATEGORI", "TRANS", "EXTYP", "AGANDE", "ANTAL"])
    end

    def add_tables()
      @xl.set_current_sheet("Lånedata")
      @xl.add_table("A1:G#{@loan_data_size+1}", "Lånetabell", "TableStyleMedium2")
      @xl.set_current_sheet("Utförare")
      @xl.add_table("A1:E#{@performer_data_size+1}", "Utförartabell", "TableStyleMedium2")
    end

    def add_pivots()
      @xl.set_current_sheet("Lån")
      @xl.add_pivot(range: "A5:G30", datasheet: "Lånedata", datarange: "A1:G#{@loan_data_size+1}",
        rows: ["KATEGORI"], columns: ["EXTYP"], data: "ANTAL", pages: ["DATUM", "TRANS", "BIBL", "AGANDE"],
        style_info: "PivotStyleMedium15")
    end

    def save_xlsx(filename)
      @xl.save(filename)
    end
  end
end

class CSVReader
  require 'csv'

  def self.read_data(filename)
    CSV.read(filename, col_sep: "\t")
  end
end

if __FILE__ == $0

end