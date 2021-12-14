using AxisArrays

# Format Parameters to be called like variables
function paramDataFormatter(setTup::Tuple, data)
    tupleAxis = Tuple([length(set) for set in setTup])
    shapedData = reshape(data, tupleAxis)
    return AxisArray(shapedData, setTup)
end

function parameter(setTup::Tuple, data)
    formattedParam = paramDataFormatter(setTup, data)
    return formattedParam
end

function parameter(set::UnitRange{Int64}, data::Float64)
    return [data]
end

function parameter(set, data)
    shapedData = reshape(data, length(set))
    return AxisArray(shapedData, set)
end
