export split_continuous
function split_continuous(arr)
    result = []
    current = []
    for i in 1:length(arr)

        if length(current) == 0 || arr[i] == current[end] + 1
            if length(current) == 0
                current = [arr[i]]
            else
                push!(current, arr[i])
            end
            
        else
            push!(result, current)
            current = [arr[i]]
        end
    end
    if length(current) > 0
        push!(result, current)
    end
    return result
end

