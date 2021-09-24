require_relative '../common/excel'
require_relative 'fetch'
# require_relative 'kb_11'
# require_relative 'kb_12'
# require_relative 'kb_14'
# require_relative 'kb_15'

module KB
  class Report
    def self.run(db, subpath, output_file, year)
      fetch = Fetch.new(db, subpath)
      data = fetch.run(year)
      # kb_11 = KB11.new(db, subpath)
      # kb_11_data = kb_11.run(year)
      # kb_12 = KB12.new(db, subpath)
      # kb_12_data = kb_12.run(year)
      # kb_14 = KB14.new(db, subpath)
      # kb_14_data = kb_14.run(year)
      # kb_15 = KB15.new(db, subpath)
      # kb_15_data = kb_15.run(year)
      # report = Report.new(kb_10_data, kb_11_data, kb_12_data, kb_14_data, kb_15_data)
      # report.save_xlsx(output_file)
    end
  end
end