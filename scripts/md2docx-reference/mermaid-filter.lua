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
  local width = 1.0 / ncols
  local new_colspecs = {}
  for i, spec in ipairs(tbl.colspecs) do
    new_colspecs[i] = {spec[1], width}
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

    os.execute("mmdc -i " .. infile .. " -o " .. outfile .. " -b white")

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
