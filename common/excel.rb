#!/usr/bin/env ruby

require 'caxlsx'

class Excel

  def initialize()
    @xl = Axlsx::Package.new
    @wb = @xl.workbook
    @styles = {}
    @grids = {}
    @merges = {}
    @tables = {}
    @pivots = {}
    @col_widths = {}
    @current_sheet = nil
  end

  def add_sheet(name, x, y)
    @grids[name] = make_grid(x, y)
    @merges[name] = []
    @tables[name] = []
    @pivots[name] = []
    @col_widths[name] = []
    if @current_sheet.nil?
      @current_sheet = name
    end
  end

  def set_current_sheet(name)
    if @grids.keys.include?(name)
      @current_sheet = name
    end
  end

  def make_grid(x, y)
    table = []
    y.times do |rownum|
      row = []
      x.times do |colnum|
        row << [nil, nil]
      end
      table << row
    end
    {table: table, meta: {}}
  end

  def add_style(name, params = {})
    xl_style = {
      bg_color: params[:bg],
      fg_color: params[:fg],
      b: params[:b],
      border: params[:border],
      sz: params[:sz]
    }.compact
    xl_alignment = {
      horizontal: params[:align],
      vertical: params[:valign],
      wrap_text: params[:wrap]
    }.compact
    xl_style[:alignment] = xl_alignment if !xl_alignment.empty?
    @styles[name] = xl_style
  end

  def add_table(range, name, style_info = nil)
    table = {range: range, name: name}
    if style_info
      table[:style_info] = {name: style_info}
    end
    @tables[@current_sheet] << table
  end

  def add_pivot(range:, datasheet:, datarange:, rows:, columns:, data:, pages:, style_info: nil)
    pivot = {
      start_range: range,
      datasheet_name: datasheet,
      datasheet_range: datarange,
      rows: rows,
      columns: columns,
      data: [{ref: data}],
      pages: pages
    }
    if style_info
      pivot[:style_info] = {name: style_info}
    end
    @pivots[@current_sheet] << pivot
  end

  def add_height(rownum, height)
    @grids[@current_sheet][:meta][:row_heights] ||= {}
    @grids[@current_sheet][:meta][:row_heights][rownum] = height
  end

  def add_merge(range)
    @merges[@current_sheet] << range
  end

  def set_column_widths(col_widths)
    @col_widths[@current_sheet] = col_widths
  end

  def cell(pos, value = nil, style = nil)
    x,y = decode_pos(pos)
    @grids[@current_sheet][:table][y][x] = [value, style]
  end

  def cell_list(start_pos, value_list, style = nil)
    cell_list_horizontal(start_pos, value_list, style)
  end

  def cell_list_vertical(start_pos, value_list, style = nil)
    x,y = decode_pos(start_pos)
    value_list.each.with_index do |value,i|
      cell_style = style.kind_of?(Array) ? style[i] : style
      @grids[@current_sheet][:table][y+i][x] = [value, cell_style]
    end
  end

  def cell_list_horizontal(start_pos, value_list, style = nil)
    x,y = decode_pos(start_pos)
    value_list.each.with_index do |value,i|
      cell_style = style.kind_of?(Array) ? style[i] : style
      @grids[@current_sheet][:table][y][x+i] = [value, cell_style]
    end
  end

  def print_grid()
    grid = @grids[@current_sheet][:table]
    grid.each.with_index do |row,i|
      values = row.map {|x| x[0]}
      puts ([i+1] + values).join("\t")
    end
  end

  def decode_pos(pos)
    if pos.kind_of?(String)
      return decode_excel_pos(pos)
    else
      return pos
    end
  end

  def encode_excel_pos(x, y)
    if x < 26
      colcode = ("A".ord + x).chr
    else
      colcode = ("A".ord + x/26).chr
      colcode += ("A".ord + x%26).chr
    end
    "#{colcode}#{y+1}"
  end

  def decode_excel_pos(pos)
    if(pos =~ /^([a-zA-Z])([a-zA-Z]?)(\d+)/)
      colcode1 = $1
      colcode2 = $2
      rownum = $3.to_i - 1
      if(colcode2.nil? || colcode2.empty?)
        colnum = colcode1.downcase.ord - "a".ord
      else
        colnum = colcode1.downcase.ord - "a".ord
        colnum *= 26
        colnum += colcode2.downcase.ord - "a".ord
      end
      return [colnum, rownum]
    end
    raise "Invalid Excel Position: #{pos}"
  end

  def write_grids_to_sheets()
    @xl_styles = gen_styles()
    sheets = {}
    @grids.keys.each do |sheet_name|
      @wb.add_worksheet(name: sheet_name) do |sheet|
        sheets[sheet_name] = sheet
        write_grid_to_sheet(@grids[sheet_name], sheet)
        @merges[sheet_name].each do |merge|
          sheet.merge_cells(merge)
        end
        sheet.column_widths(*@col_widths[sheet_name])
      end
    end

    @tables.keys.each do |sheet_name|
      @tables[sheet_name].each do |table|
        sheet = sheets[sheet_name]
        sheet.add_table(table[:range], {name: table[:name], style_info: table[:style_info]}.compact)
      end
    end

    @pivots.keys.each do |sheet_name|
      @pivots[sheet_name].each do |pivot|
        sheet = sheets[sheet_name]
        datasheet = sheets[pivot[:datasheet_name]] || sheets[sheet_name]
        pivot_table = Axlsx::PivotTable.new(pivot[:start_range], pivot[:datasheet_range], datasheet, {style_info: pivot[:style_info]}.compact)
        pivot_table.rows = pivot[:rows]
        pivot_table.columns = pivot[:columns]
        pivot_table.data = pivot[:data]
        pivot_table.pages = pivot[:pages]
        sheet.pivot_tables << pivot_table
      end
    end
  end

  def write_grid_to_sheet(grid, sheet)
    grid[:table].each.with_index do |row,i|
      row_data = []
      row_style = []
      row_height = nil
      if(grid[:meta][:row_heights])
        row_height = grid[:meta][:row_heights][i+1]
      end
      row.each do |cell|
        row_data << cell[0]
        row_style << @xl_styles[cell[1]]
      end
      sheet.add_row(row_data, style: row_style, height: row_height)
    end
  end

  def save(filename)
    write_grids_to_sheets()
    @xl.serialize(filename)
  end

  def gen_styles()
    xl_styles = {}
    styles = @wb.styles
    @styles.keys.each do |style_name|
      style = styles.add_style(@styles[style_name])
      xl_styles[style_name] = style
    end
    xl_styles
  end
end
