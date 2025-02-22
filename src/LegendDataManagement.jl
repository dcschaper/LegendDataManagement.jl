# This file is a part of LegendDataManagement.jl, licensed under the MIT License (MIT).

__precompile__(true)

module LegendDataManagement

using Dates

using Glob
using JSON
using PropDicts
using PropertyDicts
using StructArrays


include("filekey.jl")
include("dataset.jl")
include("data_config.jl")
include("props_db.jl")
include("legend_data.jl")


@static if !isdefined(Base, :get_extension)
    using Requires
end

function __init__()
    @static if !isdefined(Base, :get_extension)
        @require SolidStateDetectors = "71e43887-2bd9-5f77-aebd-47f656f0a3f0" include("../ext/LegendDataManagementSolidStateDetectorsExt.jl")
    end
end

end # module
