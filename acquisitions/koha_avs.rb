module Acquisitions
  class KohaAVs
    attr_reader :loc, :itemtype, :sigel

    def initialize(db)
      @db = db
      @loc = {}
      @itemtype = {}
      fetch_loc()
      fetch_itemtype()
      @sigel = {
          "40" => "Gm",
          "42" => "Gk",
          "44" => "G",
          "47" => "Gp",
          "48" => "Ge",
          "60" => "Ghdk",
          "62" => "Gumu",
          "66" => "Gv"
      }
    end

    def fetch_loc
      query = "SELECT authorised_value, lib FROM authorised_values WHERE category = 'LOC'"
      @db.mysql.query(query).each do |row|
        @loc[row["authorised_value"]] = row["lib"]
      end
    end

    def fetch_itemtype
      query = "SELECT itemtype, description FROM itemtypes"
      @db.mysql.query(query).each do |row|
        @itemtype[row["itemtype"]] = row["description"]
      end
    end
  end
end