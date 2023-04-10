export Float32

"""
    get_sources(con::SeisCon)

Returns an array of the source location coordinate pairs, NOT the minimum and maximum values.
Unlike `get_headers`, `get_sources` checks to make sure that SourceX and SourceY are consistant
throughout each block, that is `min == max`. 

Column 1 of the returned array is SourceX, and Column 2 is SourceY.

# Example

sx = get_sources(s)

"""
function Float32(con::SeisBlock)
    blocktraces11 = SeisBlock(Float32.(con.data)) #用float矩阵建立seisbloc floatk 格式
    blocktraces11.fileheader = con.fileheader
    blocktraces11.traceheaders = con.traceheaders
    return blocktraces11
end
