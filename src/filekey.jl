# This file is a part of LegendDataManagement.jl, licensed under the MIT License (MIT).


"""
    struct ExpSetup

Represents a LEGEND experimental setup like "l200".

Example:

```julia
setup = ExpSetup(:l200)
setup.label == :l200
string(setup) == "l200"
ExpSetup("l200") == setup
```
"""
struct ExpSetup
    label::Symbol
end
export ExpSetup

@inline ExpSetup(setup::ExpSetup) = setup

Base.:(==)(a::ExpSetup, b::ExpSetup) = a.label == b.label
Base.isless(a::ExpSetup, b::ExpSetup) = isless(a.label, b.label)

const _setup_expr = r"^([a-z][a-z0-9]*)$"

function ExpSetup(s::AbstractString)
    isnothing(match(_setup_expr, s)) && throw(ArgumentError("String \"$s\" does not look like a valid file LEGEND setup name"))
    length(s) < 3 && throw(ArgumentError("String \"$s\" is too short to be a valid LEGEND setup name"))
    length(s) > 8 && throw(ArgumentError("String \"$s\" is too long to be a valid LEGEND setup name"))
    ExpSetup(Symbol(s))
end

Base.convert(::Type{ExpSetup}, s::Symbol) = ExpSetup(s)
Base.convert(::Type{ExpSetup}, s::AbstractString) = ExpSetup(s)

# ToDo: Improve implementation
Base.print(io::IO, category::ExpSetup) = print(io, category.label)



"""
    struct DataPeriod

Represents a LEGEND data-taking period.

Example:

```julia
period = DataPeriod(2)
period.no == 2
string(period) == "p02"
DataPeriod("p02") == period
```
"""
struct DataPeriod
    no::Int
end
export DataPeriod

@inline DataPeriod(period::DataPeriod) = period

Base.:(==)(a::DataPeriod, b::DataPeriod) = a.no == b.no
Base.isless(a::DataPeriod, b::DataPeriod) = isless(a.no, b.no)

# ToDo: Improve implementation
Base.print(io::IO, period::DataPeriod) = print(io, "p$(lpad(string(period.no), 2, string(0)))")

const period_expr = r"^p([0-9]{2})$"

function DataPeriod(s::AbstractString)
    m = match(period_expr, s)
    if (m == nothing)
        throw(ArgumentError("String \"$s\" does not look like a valid file LEGEND data-run name"))
    else
        DataPeriod(parse(Int, (m::RegexMatch).captures[1]))
    end
end

Base.convert(::Type{DataPeriod}, s::AbstractString) = DataPeriod(s)



"""
    struct DataRun

Represents a LEGEND data-taking run.

Example:

```julia
r = DataRun(6)
r.no == 6
string(r) == "r006"
DataRun("r006") == r
"""
struct DataRun
    no::Int
end
export DataRun

@inline DataRun(r::DataRun) = r

Base.:(==)(a::DataRun, b::DataRun) = a.no == b.no
Base.isless(a::DataRun, b::DataRun) = isless(a.no, b.no)

# ToDo: Improve implementation
Base.print(io::IO, run::DataRun) = print(io, "r$(lpad(string(run.no), 3, string(0)))")

const run_expr = r"^r([0-9]{3})$"

function DataRun(s::AbstractString)
    m = match(run_expr, s)
    if (m == nothing)
        throw(ArgumentError("String \"$s\" does not look like a valid file LEGEND data-run name"))
    else
        DataRun(parse(Int, (m::RegexMatch).captures[1]))
    end
end

Base.convert(::Type{DataRun}, s::AbstractString) = DataRun(s)



"""
    struct DataCategory

Represents a LEGEND data category (related to a DAQ/measuring mode) like
"cal" or "phy".

Example:

```julia
category = DataCategory(:cal)
category.label == :cal
string(category) == "cal"
DataCategory("cal") == category
```
"""
struct DataCategory
    label::Symbol
end
export DataCategory

@inline DataCategory(category::DataCategory) = category

Base.:(==)(a::DataCategory, b::DataCategory) = a.label == b.label
Base.isless(a::DataCategory, b::DataCategory) = isless(a.label, b.label)

const category_expr = r"^([a-z]+)$"

function DataCategory(s::AbstractString)
    isnothing(match(category_expr, s)) && throw(ArgumentError("String \"$s\" does not look like a valid file LEGEND data category"))
    length(s) > 3 && throw(ArgumentError("String \"$s\" is too short to be a valid LEGEND data category"))
    length(s) > 6 && throw(ArgumentError("String \"$s\" is too long to be a valid LEGEND data category"))
    DataCategory(Symbol(s))
end

Base.convert(::Type{DataCategory}, s::AbstractString) = DataCategory(s)
Base.convert(::Type{DataCategory}, s::Symbol) = DataCategory(s)

# ToDo: Improve implementation
Base.print(io::IO, category::DataCategory) = print(io, category.label)



"""
    struct Timestamp

Represents a LEGEND timestamp.

Example:

```julia
timestamp = Timestamp("20221226T200846Z")
timestamp.unixtime == 1672085326
string(timestamp) == "20221226T200846Z"
````
"""
struct Timestamp
    unixtime::Int
end
export Timestamp

@inline Timestamp(timestamp::Timestamp) = timestamp

Dates.DateTime(timestamp::Timestamp) = Dates.unix2datetime(timestamp.unixtime)
Timestamp(datetime::Dates.DateTime) = Timestamp(round(Int, Dates.datetime2unix(datetime)))

function Timestamp(s::AbstractString)
    if _is_timestamp_string(s)
        Timestamp(DateTime(s, _timestamp_format))
    elseif _is_filekey_string(s)
        Timestamp(FileKey(s))
    else
        throw(ArgumentError("String \"$s\" doesn't seem to be or contain a LEGEND-compatible timestamp"))
    end
end

Base.convert(::Type{Timestamp}, s::AbstractString) = Timestamp(s)
Base.convert(::Type{Timestamp}, datetime::DateTime) = Timestamp(datetime)


Base.:(==)(a::Timestamp, b::Timestamp) = a.unixtime == b.unixtime
Base.isless(a::Timestamp, b::Timestamp) = isless(a.unixtime, b.unixtime)

Base.print(io::IO, timestamp::Timestamp) = print(io, Dates.format(DateTime(timestamp), _timestamp_format))


const _timestamp_format = dateformat"yyyymmddTHHMMSSZ"
const _timestamp_expr = r"^([0-9]{4})([0-9]{2})([0-9]{2})T([0-9]{2})([0-9]{2})([0-9]{2})Z$"

# ToDo: Remove _timestamp2datetime and _timestamp2unix
_timestamp2datetime(t::AbstractString) = DateTime(Timestamp(t))
_timestamp2unix(t::AbstractString) = Timestamp(t).unixtime
_timestamp2unix(t::Integer) = Int64(t)

_is_timestamp_string(s::AbstractString) = occursin(_timestamp_expr, s)

# ToDo: Remove _timestamp_from_string
_timestamp_from_string(s::AbstractString) = DateTime(Timestamp(s))



"""
    struct FileKey

Represents a LEGEND file key.

Example:

```julia
filekey = FileKey("l200-p02-r006-cal-20221226T200846Z")
```
"""
struct FileKey
    setup::ExpSetup
    period::DataPeriod
    run::DataRun
    category::DataCategory
    time::Timestamp
end
export FileKey

#=FileKey(
    setup::Union{Symbol,AbstractString},
    period::Integer,
    run::Integer,
    category::Union{Symbol,AbstractString},
    time::Union{Integer,AbstractString},
) = FileKey(Symbol(setup), Int(period), Int(run), Symbol(category), _timestamp2unix(time))=#


#Base.:(==)(a::FileKey, b::FileKey) = a.setup == b.setup && a.run == b.run && a.time == b.time && a.category == b.category

function Base.isless(a::FileKey, b::FileKey)
    isless(a.setup, b.setup) || isequal(a.setup, b.setup) && (
        isless(a.period, b.period) || isequal(a.period, b.period) && (
            isless(a.run, b.run) || isequal(a.run, b.run) && (
                isless(a.category, b.category) || isequal(a.category, b.category) && (
                    isless(a.time, b.time)
                )
            )
        )
    )
end


#l200-p02-r006-cal-20221226T200846Zp([0-9]{2})
const _filekey_expr = r"^([a-z][a-z0-9]*)-p([0-9]{2})-r([0-9]{3})-([a-z]+)-([0-9]{8}T[0-9]{6}Z)$"
const _filekey_relaxed_expr = r"^([a-z][a-z0-9]*)-p([0-9]{2})-r([0-9]{3})-([a-z]+)-([0-9]{8}T[0-9]{6}Z)(-.*)?$"

_is_filekey_string(s::AbstractString) = occursin(_filekey_expr, s)

@inline FileKey(filekey::FileKey) = filekey

function FileKey(s::AbstractString)
    m = match(_filekey_relaxed_expr, basename(s))
    if (m == nothing)
        throw(ArgumentError("String \"$s\" does not represent a valid file key or a compatible filename"))
    else
        x = (m::RegexMatch).captures
        FileKey(
            ExpSetup(Symbol(x[1])),
            DataPeriod(parse(Int, x[2])),
            DataRun(parse(Int, x[3])),
            DataCategory(Symbol(x[4])),
            Timestamp(x[5])
        )
    end
end

Base.convert(::Type{FileKey}, s::AbstractString) = FileKey(s)


function Base.print(io::IO, key::FileKey)
    print(io, key.setup)
    print(io, "-", DataPeriod(key))
    print(io, "-", DataRun(key))
    print(io, "-", DataCategory(key))
    print(io, "-", Timestamp(key))
end

Base.show(io::IO, key::FileKey) = print(io, "FileKey(\"$(string(key))\")")

ExpSetup(key::FileKey) = ExpSetup(key.setup)

DataPeriod(key::FileKey) = DataPeriod(key.period)
filekey_period_str(key::FileKey) = string(DataPeriod(key))

DataRun(key::FileKey) = DataRun(key.run)
filekey_run_str(key::FileKey) = string(DataRun(key))

DataCategory(key::FileKey) = DataCategory(key.category)

Timestamp(key::FileKey) = Timestamp(key.time)
Dates.DateTime(key::FileKey) = DateTime(Timestamp(key))
