require_relative '../common/excel'
require_relative 'fetch'
# require_relative 'kb_11'
# require_relative 'kb_12'
# require_relative 'kb_14'
# require_relative 'kb_15'

module KB
  class Report
    STYLES={
      "default" => {},
      "lib" => {b: true},
      "table_cell" => {border: 1},
      "title" => {bg: "ddebf7", fg: "000000", b: true, border: 1},
      "sumvalue_total" => {bg: "ddebf7", fg: "000000", b: true, border: 1},
    }
    def self.run(db, subpath, output_file, year)
      fetch = Fetch.new(db, subpath)
      data = fetch.run(year)
      # pp data
      report = Report.new(data)
      report.save_xlsx(output_file)
    end

    def initialize(data)
      @positions = {}
      @xl = Excel.new()
      setup_styles()
      kb10(data["kb10"])
      kb11(data["kb11"])
      kb12(data["kb12"])
      kb14(data["kb14"])
      kb19(data["kb19"])
      @xl.set_current_sheet("10 bestånd förvärv")
    end
  
    def kb10(data)
      @xl.add_sheet("10 bestånd förvärv", 10, 50)
      @xl.set_current_sheet("10 bestånd förvärv")
      @xl.cell_list("B4", ["", "Fysiskt bestånd", "Nyförvärv"], "title")
      @xl.cell_list("B5",  kb10_decode(data, "written_books"   ), "table_cell")
      @xl.cell_list("B6",  kb10_decode(data, "textbooks"       ), "table_cell")
      @xl.cell_list("B7",  kb10_decode(data, "audiobooks"      ), "table_cell")
      @xl.cell_list("B8",  kb10_decode(data, "daisybooks"      ), "table_cell")
      @xl.cell_list("B9",  kb10_decode(data, "subscriptions"   ), "table_cell")
      @xl.cell_list("B10", kb10_decode(data, "newspapers"      ), "table_cell")
      @xl.cell_list("B11", kb10_decode(data, "music_recordings"), "table_cell")
      @xl.cell_list("B12", kb10_decode(data, "film_tv"         ), "table_cell")
      @xl.cell_list("B13", kb10_decode(data, "microfilm"       ), "table_cell")
      @xl.cell_list("B14", kb10_decode(data, "images"          ), "table_cell")
      @xl.cell_list("B15", kb10_decode(data, "manuscripts"     ), "table_cell")
      @xl.cell_list("B16", kb10_decode(data, "interactive"     ), "table_cell")
      @xl.cell_list("B17", kb10_decode(data, "other"           ), "table_cell")
      @xl.cell_list("B18", ["Totalt", "=SUM(C5:C17)", "=SUM(D5:D17)"], "sumvalue_total")
      @xl.add_table("B4:D18", "KB10", "TableStyleMedium2")
    end

    def kb10_decode(data, code)
      decode = {
        "written_books"    => "Böcker med skriven text",
        "textbooks"        => "varav kursböcker",
        "audiobooks"       => "Ljudböcker",
        "daisybooks"       => "Talböcker Daisy",
        "subscriptions"    => "Tidskrifter m.m., antal löpande titlar",
        "newspapers"       => "Dagstidningar m.m.",
        "music_recordings" => "Musikinspelning",
        "film_tv"          => "Film, TV, radio",
        "microfilm"        => "Mikrofilm",
        "images"           => "Bild, kartor",
        "manuscripts"      => "Manuskript, noter m.m.",
        "interactive"      => "Interaktiva medier",
        "other"            => "Övrigt"
      }
      [decode[code], data["total"][code], data["acq"][code]]
    end
  
    def kb11(data)
      @xl.add_sheet("11 bestånd skönlitt", 10, 50)
      @xl.set_current_sheet("11 bestånd skönlitt")
      @xl.cell_list("B4", ["SAB H eller Dewey 800-899", "Antal"], "title")
      @xl.cell_list("B5", ["Bestånd av skönlitteratur", data], "table_cell")
    end
  
    def kb12(data)
      @xl.add_sheet("12 minoritetsspråk", 10, 50)
      @xl.set_current_sheet("12 minoritetsspråk")
      @xl.cell_list("B4", ["Språk", "Svenska", "Minoritetsspråk", "Övriga", "Totalt"], "title")
      @xl.cell_list("B5", ["Titlar fysiska", data["paper"]["svenska"], data["paper"]["minoritet"], data["paper"]["ovrigt"], "=SUM(C5:E5)"], "table_cell")
      @xl.cell_list("B6", ["Titlar e", data["elec"]["svenska"], data["elec"]["minoritet"], data["elec"]["ovrigt"], "=SUM(C6:E6)"], "table_cell")
      @xl.cell_list("B7", ["Totalt", "=SUM(C5:C6)", "=SUM(D5:D6)", "=SUM(E5:E6)", "=SUM(C7:E7)"], "table_cell")
    end
  
    def kb14(data)
      @xl.add_sheet("14 utlån ej fjärrlån", 10, 50)
      @xl.set_current_sheet("14 utlån ej fjärrlån")
      @xl.cell_list("B4", ["", "Utlån", "Omlån", "Totalt"], "title")
      @xl.cell_list("B5",  kb14_decode(data, "written_books"   ), "table_cell")
      @xl.cell_list("B6",  kb14_decode(data, "textbooks"       ), "table_cell")
      @xl.cell_list("B7",  kb14_decode(data, "audiobooks"      ), "table_cell")
      @xl.cell_list("B8",  kb14_decode(data, "daisybooks"      ), "table_cell")
      @xl.cell_list("B9",  kb14_decode(data, "subscriptions"   ), "table_cell")
      @xl.cell_list("B10", kb14_decode(data, "newspapers"      ), "table_cell")
      @xl.cell_list("B11", kb14_decode(data, "music_recordings"), "table_cell")
      @xl.cell_list("B12", kb14_decode(data, "film_tv"         ), "table_cell")
      @xl.cell_list("B13", kb14_decode(data, "microfilm"       ), "table_cell")
      @xl.cell_list("B14", kb14_decode(data, "images"          ), "table_cell")
      @xl.cell_list("B15", kb14_decode(data, "manuscripts"     ), "table_cell")
      @xl.cell_list("B16", kb14_decode(data, "interactive"     ), "table_cell")
      @xl.cell_list("B17", kb14_decode(data, "other"           ), "table_cell")
      @xl.cell_list("B18", ["Totalt", "=SUM(C5:C17)", "=SUM(D5:D17)", "=SUM(E5:E17)"], "sumvalue_total")
      @xl.add_table("B4:E18", "KB10", "TableStyleMedium2")
    end

    def kb14_decode(data, code)
      decode = {
        "written_books"    => "Böcker med skriven text",
        "textbooks"        => "varav kursböcker",
        "audiobooks"       => "Ljudböcker",
        "daisybooks"       => "Talböcker Daisy",
        "subscriptions"    => "Tidskrifter, seriella publikationer, m.m.",
        "newspapers"       => "Dagstidningar m.m.",
        "music_recordings" => "Musikinspelning",
        "film_tv"          => "Film, TV, radio",
        "microfilm"        => "Mikrofilm",
        "images"           => "Bild, kartor",
        "manuscripts"      => "Manuskript m.m.",
        "interactive"      => "Interaktiva medier",
        "other"            => "Övrigt"
      }
      issues = data["issues"][code]
      renews = data["renews"][code]
      [decode[code], issues, renews, issues.to_i + renews.to_i]
    end
  
    def kb19(data)
      @xl.add_sheet("19 Hur många aktiva låntagare", 10, 50)
      @xl.set_current_sheet("19 Hur många aktiva låntagare")
      @xl.cell_list("B4", ["Låntagare", "Antal"], "title")
      @xl.cell_list("B5", ["Kvinnor", data["female"]], "table_cell")
      @xl.cell_list("B6", ["Män", data["male"]], "table_cell")
      @xl.cell_list("B7", ["Övriga", data["other"]], "table_cell")
      @xl.cell_list("B8", ["Totalt", "=SUM(C5:C7)"], "sumvalue_total")
      @xl.cell_list("B9", ["", ""], "table_cell")
      @xl.cell_list("B10", ["", ""], "table_cell")
      @xl.cell_list("B11", ["varav under 18", data["lowage"]], "table_cell")
    end

    def setup_styles()
      STYLES.keys.each do |key|
        @xl.add_style(key, STYLES[key])
      end
    end

    def save_xlsx(filename)
      @xl.save(filename)
    end
  end
end