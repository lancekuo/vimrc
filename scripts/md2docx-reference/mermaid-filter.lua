-- Pandoc Lua filter:
--   1. Renders mermaid code blocks to PNG via mmdc
--   2. Strips heading bookmarks/anchors from docx output
local system = require("pandoc.system")

function Header(el)
  el.identifier = ""
  return el
end

function Table(tbl)
  local ncols = #tbl.colspecs

  -- Measure avg + max content length per column across all rows
  local max_len = {}
  local sum_len = {}
  local row_count = 0
  for i = 1, ncols do max_len[i] = 1; sum_len[i] = 0 end

  local function measure_rows(rows)
    for _, row in ipairs(rows) do
      local cells = row.cells or row
      row_count = row_count + 1
      for i, cell in ipairs(cells) do
        if i <= ncols then
          local text = pandoc.utils.stringify(cell)
          sum_len[i] = sum_len[i] + #text
          if #text > max_len[i] then max_len[i] = #text end
        end
      end
    end
  end

  -- Measure header rows
  if tbl.head and tbl.head.rows then
    measure_rows(tbl.head.rows)
  end
  -- Measure body rows
  for _, body in ipairs(tbl.bodies) do
    if body.body then measure_rows(body.body) end
  end

  -- Use blend of max and avg to avoid short columns being too wide
  -- (e.g. "#" column with max_len=1 shouldn't get 33% of a 3-col table)
  local effective = {}
  for i = 1, ncols do
    local avg = row_count > 0 and (sum_len[i] / row_count) or max_len[i]
    effective[i] = (max_len[i] + avg) / 2
  end

  -- Calculate proportional widths
  local total = 0
  for i = 1, ncols do total = total + effective[i] end

  local new_colspecs = {}
  for i, spec in ipairs(tbl.colspecs) do
    local w = effective[i] / total
    if w < 0.05 then w = 0.05 end
    new_colspecs[i] = {spec[1], w}
  end

  -- Normalize so widths sum to 1.0
  local sum = 0
  for i = 1, ncols do sum = sum + new_colspecs[i][2] end
  for i = 1, ncols do
    new_colspecs[i][2] = new_colspecs[i][2] / sum
  end

  tbl.colspecs = new_colspecs
  return tbl
end

local function escape_xml(s)
  return s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
end

function CodeBlock(block)
  if block.classes[1] == "mermaid" then
    local infile = os.tmpname() .. ".mmd"
    local outfile = os.tmpname() .. ".png"

    local f = io.open(infile, "w")
    f:write(block.text)
    f:close()

    os.execute("mmdc -i " .. infile .. " -o " .. outfile .. " -b white -s 5")

    os.remove(infile)
    return pandoc.Para({pandoc.Image({}, outfile)})
  end

  -- Regular code blocks: light gray background via raw OpenXML
  if FORMAT == "docx" then
    local paragraphs = {}
    for line in (block.text .. "\n"):gmatch("(.-)\n") do
      local xml = '<w:p>'
        .. '<w:pPr>'
        .. '<w:pStyle w:val="SourceCode"/>'
        .. '<w:shd w:val="clear" w:color="auto" w:fill="F2F2F2"/>'
        .. '<w:spacing w:after="0" w:line="240" w:lineRule="auto"/>'
        .. '</w:pPr>'
        .. '<w:r>'
        .. '<w:rPr>'
        .. '<w:shd w:val="clear" w:color="auto" w:fill="F2F2F2"/>'
        .. '</w:rPr>'
        .. '<w:t xml:space="preserve">' .. escape_xml(line) .. '</w:t>'
        .. '</w:r>'
        .. '</w:p>'
      table.insert(paragraphs, xml)
    end
    return pandoc.RawBlock('openxml', table.concat(paragraphs, "\n"))
  end
end
