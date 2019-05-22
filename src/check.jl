"""

	check_eval_param(eval,param)

Check consistency of eval(x) and nomadParameters given as arguments for runopt

"""
function check_eval_param(eval::Function,param::nomadParameters;sgte::Function=(f(x)=(false,false,nothing)))

	param.dimension = length(param.x0)
	check_everything_set(param)
	check_ranges(param)
	check_bounds(param)
	check_input_types(param)
	check_granularity(param)
	check_output_types(param.output_types)
	check_eval(eval,param)
	check_sgte(sgte,eval,param)

end

######################################################
		   	  	  #CHECKING METHODS#
######################################################

function check_everything_set(p)
	p.dimension > 0 ? nothing : error("NOMAD.jl error : wrong parameters, empty initial point x0")
	length(p.output_types) > 0 ? nothing : error("NOMAD.jl error : wrong parameters, empty output types vector")
end

function check_ranges(p)
	p.dimension <= 1000 ? nothing : error("NOMAD.jl error : dimension needs to be inferior to 1000")
	p.max_bb_eval >= 0 ? nothing : error("NOMAD.jl error : wrong parameters, negative max_bb_eval")
	(0<=p.display_degree<=3) ? nothing : error("NOMAD.jl error : wrong parameters, display degree should be between 0 and 3")
end

function check_bounds(p)
	if length(p.lower_bound)>0
		length(p.lower_bound) == p.dimension ? nothing : error("NOMAD.jl error : wrong parameters, size of lower bound does not match dimension of the problem")
		for i=1:p.dimension
			p.lower_bound[i]<=p.x0[i] ? nothing : error("NOMAD.jl error : wrong parameters, initial state x0 is outside the bounds")
		end
	end

	if length(p.upper_bound)>0
		length(p.upper_bound) == p.dimension ? nothing : error("NOMAD.jl error : wrong parameters, size of upper bound does not match dimension of the problem")
		for i=1:p.dimension
			p.x0[i]<=p.upper_bound[i] ? nothing : error("NOMAD.jl error : wrong parameters, initial state x0 is outside the bounds")
		end
	end

	if (length(p.lower_bound)>0) && (length(p.upper_bound)>0)
		for i=1:p.dimension
			p.lower_bound[i]<p.upper_bound[i] ? nothing : error("NOMAD.jl error : wrong parameters, lower bounds should be inferior to upper bounds")
		end
	end
end

function check_input_types(p)
	if length(p.input_types)==0
		p.input_types=fill("R",p.dimension)
	elseif length(p.input_types)==p.dimension
		for i=1:p.dimension
			if p.input_types[i]=="I"
				try
					convert(Int64,p.x0[i])
				catch
					error("NOMAD.jl error : wrong parameters, coordinate $i of inital point x0 is not an integer as specified in nomadParameters.input_types")
				end
			elseif p.input_types[i]=="B"
				p.x0[i] in [0,1] ? nothing : error("NOMAD.jl error : wrong parameters, coordinate $i of inital point x0 is not binary as specified in nomadParameters.input_types")
			elseif p.input_types[i] != "R"
				error("NOMAD.jl error : wrong parameters, unknown input type $(p.input_types[i])")
			end
		end
	else
		error("NOMAD.jl error : wrong parameters, number of input types does not match problem dimension")
	end
end

function check_granularity(p)
	length(p.granularity)==p.dimension || error("NOMAD.jl error : wrong parameters, nomadParameters.granularity does not have the same dimension as the initial point")
	for i=1:p.dimension
		if p.input_types[i]=="R"
			p.granularity[i]>=0 || error("NOMAD.jl error : wrong parameters, $(i)th coordinate of nomadParameters.granularity is negative")
			try
				p.granularity[i]==0 || Int(p.x0[i]/p.granularity[i])
			catch
				error("NOMAD.jl error : wrong parameters, $(i)th coordinate of initial point is not a multiple of $(i)th granularity")
			end
		elseif p.input_types[i] in ["I","B"]
			p.granularity[i] in [0,1] || warn("NOMAD.jl warning : $(i)th coordinate of nomadParameters.granularity is automatically set to 1")
			p.granularity[i]=1
		end
	end
end

function check_output_types(ot)
	count_obj = 0
	count_avg = 0
	count_sum = 0
	for  i=1:length(ot)
		if ot[i]=="OBJ"
			count_obj = count_obj + 1
		elseif ot[i]=="STAT_AVG"
			count_obj = count_avg + 1
		elseif ot[i]=="STAT_SUM"
			count_obj = count_sum + 1
		end
		if !(ot[i] in ["OBJ","EB","PB","CNT_EVAL","NOTHING","-","UNDEFINED_BBO","CSTR","PEB","STAT_AVG","STAT_SUM","F","FILTER","PEB_E","PEB_P"])
			error("NOMAD.jl error : wrong parameters, unknown output type $(ot[i])")
		end
	end
	count_obj > 0 ? nothing : error("NOMAD.jl error : wrong parameters, at least one objective function is needed (set one OBJ in nomadParameters.output_types)")
	count_obj <= 1 ? nothing : error("NOMAD.jl error : multi-objective MADS is not supported by NOMAD.jl (do not set more than one OBJ in nomadParameters.output_types)")
	count_avg <= 1 ? nothing : error("NOMAD.jl error : wrong parameters, cannot set more than one STAT_AVG in nomadParameters.output_types")
	count_sum <= 1 ? nothing : error("NOMAD.jl error : wrong parameters, cannot set more than one STAT_SUM in nomadParameters.output_types")

	if ("F" in ot) && (("PEB" in ot) || ("PEB_E" in ot) || ("PEB_P" in ot) || ("PB" in ot) || ("CSTR" in ot))
		error("NOMAD.jl error : F constraint is not compatible with PB and PEB constraints")
	end
end

function check_eval(ev,p)

	(success,count_eval,bb_outputs)=ev(p.x0)

	typeof(success)==Bool ? nothing : error("NOMAD.jl error : success returned by eval(x) is not a boolean")
	typeof(count_eval)==Bool ? nothing : error("NOMAD.jl error : count_eval returned by eval(x) is not a boolean")
	success ? nothing : error("NOMAD.jl error : success needs to be true for initial point x0")

	try
		bb_outputs=Float64.(bb_outputs)
	catch
		error("NOMAD.jl error : bb_outputs returned by eval(x) needs to be convertible to Vector{Float64}")
	end

	length(bb_outputs)==length(p.output_types) ? nothing : error("NOMAD.jl error : wrong parameters, dimension of bb_outputs returned by eval(x) does not match number of output types set in parameters")
end

function check_sgte(sg,ev,p)

	(success,count_eval,bb_outputs)=sg(p.x0)

	if !isnothing(bb_outputs)
		typeof(success)==Bool ? nothing : error("NOMAD.jl error : success returned by surrogate(x) is not a boolean")
		typeof(count_eval)==Bool ? nothing : error("NOMAD.jl error : count_eval returned by surrogate(x) is not a boolean")

		try
			bb_outputs=Float64.(bb_outputs)
		catch
			error("NOMAD.jl error : bb_outputs returned by surrogate(x) needs to be convertible to Vector{Float64}")
		end

		length(bb_outputs)==length(p.output_types) ? nothing : error("NOMAD.jl error : wrong parameters, dimension of bb_outputs returned by surrogate(x) does not match number of output types set in parameters")
	end
end