export get_box_indexs
# using GR #meshgrid
#  测试函数indexs=get_box_indexs(1653,1712,2280,3300,120,1021,1653,2280)
function get_box_indexs(inline_1, inline_2, xline_1, xline_2, n1, n2, inline_s=1, xline_s=1)
    # GET_BOX_INDEXS 获取内部方块的下标 
    # 默认第一个点的坐标为（1,1）
    # 1 不变 inline 2 变 xline ，故而x代表inline  y代表xline
    # 此处显示详细说明 

    index_y1 = inline_1 - inline_s + 1
    index_y2 = inline_2 - inline_s + 1  # 相对坐标
    index_x1 = xline_1 - xline_s + 1
    index_x2 = xline_2 - xline_s + 1  # 相对坐标

    # 建立坐标网格 1,1 坐标起点
    traces = 1:n1*n2
    surf = reshape(traces, n2, n1)  # 建立坐标网格

    # 处理内部方块坐标程序，
    index_xs = index_x1:index_x2
    index_ys = index_y1:index_y2

    INDEX_XS, INDEX_YS = meshgrid(index_xs, index_ys)  # INDEX_XS 是第一个坐标，按 
    # INDEX_XS = INDEX_XS'
    # INDEX_YS = INDEX_YS'

    indexs = Int64[]
    for i = 1:length(index_xs)*length(index_ys)
        push!(indexs, (INDEX_YS[i]-1) * n2 + INDEX_XS[i])
    end

    return indexs
end