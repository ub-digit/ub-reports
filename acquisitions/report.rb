require_relative '../common/db'
require_relative 'fetch'
require_relative '../common/excel'
require_relative 'koha_avs'

module Acquisitions
  class Report
    STYLES={
      "default" => {},
      "lib" => {b: true},
      "title" => {bg: "ddebf7", fg: "000000", b: true},
      "kurs_title" => {bg: "c9c9c9", b: true, border: 1},
      "kurs_cell" => {bg: "ffff00", border: 1},
      "bordered" => {border: 1},
      "bordered_bold" => {border: 1, b: true},
      "bold" => {b: true},
      "itemtype" => {b: true},
      "kurs" => {bg: "ffff00", fg: "000000"},
      "sigel_kurs_k" => {bg: "ffc000"},
      "sigel_kurs_k_title" => {bg: "ffc000", b: true},
      "sigel_kurs_f" => {bg: "f8cbad"},
      "sigel_kurs_f_title" => {bg: "f8cbad", b: true},
      "sigel_kurs_total" => {bg: "fff2cc"},
      "sigel_kurs_total_title" => {bg: "fff2cc", b: true},
    }
    def self.run(db, subpath, output_file, year)
      fetcher = Fetch.new(db, subpath)
      data = fetcher.run(year)
      report = Report.new(data)
      report.save_xlsx(output_file)
    end

    def initialize(data)
      @positions = {}
      @xl = Excel.new()
      @sheet = data["year"]
      @xl.add_sheet(@sheet, 15, 10000)
      setup_styles()
      place_tables(data)
      col_widths = [2.3, 1.3, 0.75, 0.75, 2.3, 1.3, 0.75, 0.75, 1.3, 2.3, 1.3, 0.75]
      @xl.set_column_widths(col_widths.map {|x| x*12 })
      @xl.add_sheet("Sammanfattning", 15, 1000)
      @xl.set_current_sheet("Sammanfattning")
      place_sigel_tables(data["sigel"])
      place_total_table(data["total"])
      col_widths = [1.3, 1.3, 0.75, 0.75, 1.3, 1.3, 0.75, 0.75, 1.3, 0.75, 1.3, 0.75, 1.3, 0.75]
      @xl.set_column_widths(col_widths.map {|x| x*12 })
    end

    def setup_styles()
      STYLES.keys.each do |key|
        @xl.add_style(key, STYLES[key])
      end
    end

    def place_tables(data)
      heights = heights(data)
      current_row = 4
      @libs.each do |lib|
        k_lib = "#{lib}_K"
        f_lib = "#{lib}_F"
        lib_tables_rows = heights[lib]["max"]
        @xl.cell("A#{current_row}", k_lib, "lib")
        @xl.cell("E#{current_row}", f_lib, "lib")
        place_table([0, current_row], data["library"][k_lib], data["library_total"][k_lib])
        place_table([4, current_row], data["library"][f_lib], data["library_total"][f_lib])
        current_row += lib_tables_rows + 2
      end
      place_kurs_table([8, 7], data["kursbok"])
    end

    def place_table(start_cell, data, totals)
      return if(data.nil?)
      x, y = start_cell
      @xl.cell_list(start_cell, ["Extyp / lokalisering", "Antal bibposter", "Antal ex"], "title")
      y += 1
      data.keys.sort.each do |itemtype|
        @xl.cell_list([x, y], [itemtype, data[itemtype]["bibs"], data[itemtype]["items"]], "itemtype")
        y += 1
        locs = data[itemtype]["locs"]
        locs.keys.sort.each do |loc|
          style = locs[loc]["is_kurs"] ? "kurs" : "default"
          @xl.cell_list([x, y], ["  #{loc}", locs[loc]["bibs"], locs[loc]["items"]], style)
          y += 1
        end
      end
      @xl.cell_list([x, y], ["Totalsumma", totals["bibs"], totals["items"]], "title")
    end

    def place_kurs_table(start_cell, data)
      x, y = start_cell
      sum_top_bib = @xl.encode_excel_pos(x+2, y+1)
      sum_top_item = @xl.encode_excel_pos(x+3, y+1)
      @xl.cell_list(start_cell, ["Extyp", "Lokalisering", "Antal bibposter", "Antal ex"], "kurs_title")
      y += 1
      data.keys.sort.each do |itloc|
        itemtype,loc = itloc
        @xl.cell_list([x, y], [itemtype, loc, data[itloc]["bibs"], data[itloc]["items"]], "kurs_cell")
        y += 1
      end
      sum_bottom_bib = @xl.encode_excel_pos(x+2, y-1)
      sum_bottom_item = @xl.encode_excel_pos(x+3, y-1)
      
      @xl.cell_list([x, y], 
        ["TOTALT:", nil, 
          "=SUM(#{sum_top_bib}:#{sum_bottom_bib})", 
          "=SUM(#{sum_top_item}:#{sum_bottom_item})"],
        ["kurs_cell", "bordered", "bordered", "bordered"])
    end

    def place_sigel_tables(data)
      @xl.cell("A3", "KÖPTA", "bold")
      @xl.cell("E3", "FÅDDA", "bold")
      @xl.cell("I2", "Varav kursböcker", "bold")
      @xl.cell_list("A4", ["Bibl", "Antal bibposter", "Antal ex"], "title")
      @xl.cell_list("E4", ["Bibl", "Antal bibposter", "Antal ex"], "title")
      @xl.cell_list("I3", 
        ["Köpta", nil, "Fådda", nil, "Totalt kursböcker", nil],
        [
          "sigel_kurs_k_title", "sigel_kurs_k_title", 
          "sigel_kurs_f_title", "sigel_kurs_f_title", 
          "sigel_kurs_total_title", "sigel_kurs_total_title"
        ])
      @xl.cell_list("I4", 
        ["Antal bibposter", "Antal ex", "Antal bibposter", "Antal ex", "Antal bibposter", "Antal ex"],
        [
          "sigel_kurs_k_title", "sigel_kurs_k_title", 
          "sigel_kurs_f_title", "sigel_kurs_f_title", 
          "sigel_kurs_total_title", "sigel_kurs_total_title"
        ])
      table_offset = 4
      data.keys.sort.each.with_index do |sigel,i|
        @xl.cell_list([0, table_offset+i], [sigel, data[sigel]["bibs_k"], data[sigel]["items_k"]], "bold")
        @xl.cell_list([4, table_offset+i], [sigel, data[sigel]["bibs_f"], data[sigel]["items_f"]], "bold")
        @xl.cell_list([8, table_offset+i], 
          [
            data[sigel]["bibs_kurs_k"], data[sigel]["items_kurs_k"],
            data[sigel]["bibs_kurs_f"], data[sigel]["items_kurs_f"],
            data[sigel]["bibs_kurs"], data[sigel]["items_kurs"],
          ],
          [
            "sigel_kurs_k", "sigel_kurs_k",
            "sigel_kurs_f", "sigel_kurs_f",
            "sigel_kurs_total", "sigel_kurs_total",
          ])
      end

      sigel_count = data.keys.size

      @xl.cell_list([0, sigel_count+table_offset], 
        [
          "Totalsumma",
          sum_above(1, table_offset, table_offset+sigel_count-1),
          sum_above(2, table_offset, table_offset+sigel_count-1)
        ], "title")
      @xl.cell_list([4, sigel_count+table_offset], 
        [
          "Totalsumma",
          sum_above(5, table_offset, table_offset+sigel_count-1),
          sum_above(6, table_offset, table_offset+sigel_count-1)
        ], "title")
    end

    def sum_above(colnum, rownum_start, rownum_end)
      pos_start = @xl.encode_excel_pos(colnum, rownum_start)
      pos_end = @xl.encode_excel_pos(colnum, rownum_end)
      "=SUM(#{pos_start}:#{pos_end})"
    end

    def place_total_table(data)
      @xl.cell_list("B18", ["Totalt UB", nil, nil, "Varav kursböcker", nil], "bordered_bold")
      @xl.cell_list("B19", ["Bibposter", "Ex", nil, "Bibposter", "Ex"], "bordered_bold")
      @xl.cell_list("B20", [data["bibs"], data["items"], nil, data["bibs_kurs"], data["items_kurs"]], "bordered_bold")
    end

    def heights(data)
      blocks = {}
      data["library"].keys.sort.each do |lib|
        itemtypes_count = data["library"][lib].keys.size
        locations_count = data["library"][lib].map{|itype,vals| vals["locs"].keys.size}.sum
        blocks[lib] = itemtypes_count + locations_count + 3
      end
      heights = {}
      @libs = blocks.keys.map{|l| l[/^(.*)_[FK]$/,1]}.uniq.sort
      @libs.each do |main|
        f_height = blocks["#{main}_F"] || 0
        k_height = blocks["#{main}_K"] || 0
        max_height = [f_height, k_height].max
        heights[main] = {"F" => f_height, "K" => k_height, "max" => max_height}
        heights["#{main}_F"] = heights[main]
        heights["#{main}_K"] = heights[main]
      end
      heights
    end

    def save_xlsx(filename)
      @xl.save(filename)
    end
  end
end

if __FILE__ == $0
  db = DB.new()
  fetcher = Fetch.new(db)
  data = fetcher.run("2020")
  report = Report.new(data)
  report.save_xlsx("temp/test.xlsx")
  # pp data
end
