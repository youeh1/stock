# a structure for stock, either for buy or initializing
mutable struct stock
    purchase_value::Float64
    purchase_date::Time
    hold::Bool
    sold::Bool
    sold_date::Time
    sold_value::Float64

    function stock(purchase_value::Float64,purchase_date::Time) # a new stock in an accunt
        t = new()
        t.purchase_value = purchase_value
        t.purchase_date = purchase_date
        t.hold = true
        t.sold = false
        t.sold_date = Time(9999,12,31,"PM",11,59) # having not being sold means the sold date is extremely far future ex 9999
        t.sold_value = 0.0
        t
    end
end

mutable struct company
    name::String
    hold::Array{stock,1}
    sold::Array{stock,1}
end

mutable struct whole_stocks
    company_names::Dict{String,Int64}
    companies::Array{company,1}
end
#

# either buy or sell
# if the transaction is the first time, initialize a company object and a hold stock array
function transactions(ws::whole_stocks,tr::String)

    # knowing the name of a company or whether the transaction is buying or selling
    # which one should be the first?
    BuyorSell = !isnothing(findfirst("buy",tr))
    name = name_share(tr) # extract the name of the current transaction
    value = value_share(tr)
    num = num_shares(BuyorSell,tr)
    dates = date_share(tr)
    # check whether it is the first account
    # check whether the name is already exist
    # if so, do the trasaction within the object
    # if not, create a new company object
    if new_stocks(ws.company_names,name)
        # push!(ws.company_names,name)
        f = company(name,stock[],stock[])
        push!(ws.companies,f)
    end
    #
    if BuyorSell # is this transaction buying or selling
        # buy
        st = stock(value,dates)
        buy!(ws,st,num,name)
        println("I just bought $(num) share(s) of $(name) at $(value)")
    else
        #sell
        FIFO_sell!(ws,name,num,value,dates)
        # println("Im selling now")
    end
end

function new_stocks(company_names::Dict{String,Int64},sn::String)
    if !(sn in keys(company_names))
        company_names[sn] = length(company_names)+1
        return true
    end
    return false
end

function buy!(ws::whole_stocks,s::stock,num::Int64,name::String)
    com = ws.company_names[name]
    for i = 1:num
        push!(ws.companies[com].hold,s)
    end
end

#first comes first outs:
function FIFO_sell!(ws::whole_stocks,name::String,num::Int64,sold_value::Float64,sold_times::Time)
    if length(ws.companies[ws.company_names[name]].hold) >= num
        for trans = 1:num
            # sold_one = popfirst!(ws.companies[ws.company_names[name]].hold)
            sold_one = deepcopy(popfirst!(ws.companies[ws.company_names[name]].hold))
            
            sold_one.hold = false
            sold_one.sold = true
            sold_one.sold_date = sold_times
            sold_one.sold_value = sold_value
            push!(ws.companies[ws.company_names[name]].sold,sold_one)
        end
    else
        println("you cant sold the stocks anymore, already sold")
    end
    total = 0.0
    for i = 1: length(ws.company_names)
        pr = calculate_profit!(ws.companies[i].sold)
        println("Compnay:$(ws.companies[i].name) currently $(pr) gained")
        total += pr
    end
    println("total gains: $(total)\$")
    println("")

end
#
function calculate_profit!(ss::Array{stock,1})
    profit = 0.0
    for s = 1:length(ss)
        profit += (ss[s].sold_value - ss[s].purchase_value)
    end
    return profit
end


## old version
# mutable struct whole_stocks
#     company_names::Array{String,1}
#     companies::Array{company,1}
# end

# function new_stocks(ws::whole_stocks,sn::String)
#     for i = 1:length(ws.company_names)
#         if ws.company_names[i] == sn
#             return false
#         end
#     end
#     return true
# end

# function company_list(ws::Array{String},name::String)
#
#     for i = 1:length(ws)
#         if ws[i] == name
#             return i
#         end
#     end
# end

# function sold_one(s::stock,st_::Time,sv_::Float64)
#     s.sold_date = st_
#     s.sold_value = sv_
#     nothing
# end
#
