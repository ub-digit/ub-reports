#!/usr/bin/env ruby

require_relative '../common/excel'
require_relative 'fetch'

module Yearly
  class Report
    LIB={
      "40" => "Gm",
      "42" => "Gk",
      "44" => "G",
      "47" => "Gp",
      "48" => "Ge",
      "60" => "Ghdk",
      "62" => "Gumu",
      "66" => "Gv"
    }
    LIBROW={
      "40" => 9,
      "42" => 10,
      "44" => 11,
      "47" => 12,
      "48" => 13,
      "60" => 14,
      "62" => 15,
      "66" => 16
    }
    STYLES={
      "default" => {bg: "ffffff", fg: "000000"},
      "sv_head" => {bg: "ffff00", fg: "000000", wrap: true, align: :center, valign: :center},
      "for_head" => {bg: "800000", fg: "ffffff", wrap: true, align: :center, valign: :center},
      "title" => {bg: "ddebf7", fg: "000000", b: true},
      "sumvalue_total" => {bg: "ddebf7", fg: "000000", b: true},
      "top_head" => {bg: "c0c0c0", fg: "000000", align: :center},
      "renewvalue" => {bg: "fff2cc", fg: "000000"},
      "sumvalue" => {bg: "d9d9d9", fg: "000000"},
      "libname" => {b: true}
    }

    def self.run(db, subpath, output_file, year)
      fetcher = Fetch.new(db, subpath)
      data = fetcher.fetch_all(year)
      report = Report.new(data)
      report.save_xlsx(output_file)
    end

    def initialize(data)
      @xl = Excel.new()
      @data = data
      setup_sheet()
      setup_styles()
      header()
      fill_data()
    end

    def setup_sheet()
      @xl.add_sheet("Blad 1", 25, 25)
    end

    def setup_styles()
      STYLES.keys.each do |key|
        @xl.add_style(key, STYLES[key])
      end
    end

    def header()
      @xl.cell("A6", @data["year"])
      @xl.cell("B6", "FJÄRRUTLÅN", "top_head")
      @xl.cell("L6", "HEMLÅN", "top_head")
      @xl.cell("Q6", "FJÄRRINLÅN", "top_head")
      @xl.cell("W6", "EJ AVHÄMTADE/LÅNADE FJÄRRINLÅN", "top_head")
      @xl.cell("B7", "Svenska bibliotek", "sv_head")
      @xl.cell("G7", "Utländska bibliotek", "for_head")
      @xl.cell("Q7", "Svenska bibliotek", "sv_head")
      @xl.cell("R7", "Utländska bibliotek", "for_head")
      @xl.cell("S7", "", "sumvalue")
      @xl.cell("T7", "", "sumvalue")
      @xl.cell("X7", "Svenska bibliotek", "sv_head")
      @xl.cell("Y7", "Utländska bibliotek", "for_head")
      @xl.cell("Z7", "Totalt", "title")
      @xl.cell_list("A8", [
        "BIBLIOTEK",
        "Initiala", "Omlån tot", "vanliga", "auto", "Summa",
        "Initiala", "Omlån tot", "vanliga", "auto", "Summa",
        "Initiala", "Omlån tot", "vanliga", "auto", "Summa",
        "Initiala", "Initiala", "Auto", "*Summa",
        "**Totalt antal lån"
      ], "title")
      @xl.add_height(7, 50)
      @xl.add_merge("B6:K6")
      @xl.add_merge("L6:P6")
      @xl.add_merge("Q6:T6")
      @xl.add_merge("W6:Z6")
      @xl.add_merge("B7:F7")
      @xl.add_merge("G7:K7")
      LIBROW.keys.each do |libcode|
        rownum = LIBROW[libcode] - 1
        @xl.cell([0, rownum], LIB[libcode], "libname")
      end
      min,max = librow_range()
      @xl.cell([0, max], "Totalsumma", "title")
      20.times do |i|
        @xl.cell([i+1, max], sum_above(i+1, min-1, max-1), "sumvalue_total")
      end
      LIBROW.values.each do |rownum|
        pos = "U#{rownum}"
        @xl.cell(pos, "=B#{rownum}+G#{rownum}+L#{rownum}+Q#{rownum}+R#{rownum}")
      end
      @xl.cell("W8", "Summa", "sumvalue_total")
      col_widths = [11.4]*26
      @xl.set_column_widths(col_widths)
    end

    def fill_data()
      LIB.keys.each do |lib|
        fill_data_normal("B", "illout_sv", lib)
        fill_data_normal("G", "illout_for", lib)
        fill_data_normal("L", "homeloan", lib)
        fill_data_illin("Q", "illin", lib)
      end
      fill_data_illin_unissued("X8")
    end

    def sum_above(colnum, rownum_start, rownum_end)
      pos_start = @xl.encode_excel_pos(colnum, rownum_start)
      pos_end = @xl.encode_excel_pos(colnum, rownum_end)
      "=SUM(#{pos_start}:#{pos_end})"
    end

    def librow_range()
      [LIBROW.values.min, LIBROW.values.max]
    end

    def fill_data_illin_unissued(start_cell)
      hashdata = @data["illin"]["unissued"]
      se_sum = hashdata["se"]
      for_sum = hashdata["for"]
      total_sum = se_sum + for_sum
      @xl.cell_list(start_cell, [se_sum, for_sum, total_sum], "sumvalue_total")
    end

    def fill_data_normal(start_col_excel, name, lib)
      rownum = LIBROW[lib]
      start_pos = "#{start_col_excel}#{rownum}"
      hashdata = @data[name][lib]
      rowdata = [0]*5
      if hashdata && !hashdata.empty?
        rowdata = [
          hashdata["initial"],
          hashdata["renewals_total"],
          hashdata["renewals_manual"],
          hashdata["renewals_auto"],
          hashdata["total"],
        ]
      end
      @xl.cell_list(start_pos, rowdata, 
        [nil, nil, "renewvalue", "renewvalue", "sumvalue"])
    end

    def fill_data_illin(start_col_excel, name, lib)
      rownum = LIBROW[lib]
      start_pos = "#{start_col_excel}#{rownum}"
      hashdata = @data[name][lib]
      rowdata = [0]*4
      if hashdata && !hashdata.empty?
        rowdata = [
          hashdata["initial_sv"],
          hashdata["initial_for"],
          hashdata["renewals"],
          hashdata["total"],
        ]
      end
      @xl.cell_list(start_pos, rowdata,
        [nil, nil, nil, "sumvalue"])
    end

    def save_xlsx(filename)
      @xl.save(filename)
    end
  end
end

# if __FILE__ == $0
#   if ARGV[0].nil? || ARGV[0].empty? || ARGV[1].nil? || ARGV[1].empty?
#     puts "Usage: $0 year output-file.xlsx"
#     exit 0
#   end
#   fetcher = Fetch.new()
#   year = ARGV[0]
#   output_file = ARGV[1]
#   data = fetcher.fetch_all(year)
#   r = Report.new(data)
#   r.save_xlsx(output_file)
# end