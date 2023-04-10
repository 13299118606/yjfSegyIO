export segy_change

function segy_change(file::String, block::SeisBlock，indexs::AbstractVector )

    # Open buffer for writing
    s = open(file, "r+")

    # Write FileHeader  #主要检查3200-3600的二进制文件头是否一样，只有文件头一样才可以合并和改变
    check_fileheader(s, block.fileheader)

    # Write Data
    ns,ntraces = size(block.data)
    # 寻找相应的道头index，通过index来寻找就行
    # 
    for t in 1:ntraces
    idnex=(indexs[i]-1)*tracesize  #寻找相应的字节数
    # 寻找相应的道头index，通过index来寻找就行
    offset=1
	write_trace(seek(s,offset), block, t)
    end

    close(s)
end
