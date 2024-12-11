function Meta(meta)
	local formatted_date = os.date("%e %B, %Y")
	meta.build_year = os.date("%Y")
	meta.build_date = formatted_date:match("^%s*(.-)$")
	return meta
end
