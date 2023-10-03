@tool
extends Node
class_name TextParser

var re := RegEx.new()
var result : RegExMatch
var replacement := ""

func parse(text:String) -> String:
	return text

func replace_regex_match(text:String, result:RegExMatch, replacement:String) -> String:
	
	var start_string := text.substr(0, result.get_start())
	var end_string := text.substr(result.get_end(), text.length())
	return start_string + replacement + end_string

func parse_variable(text:String, placeholder:String, variable:String, value) -> String:
	var re = RegEx.new()
	var output = "" + text

	var regex = placeholder.replace("[", "\\[")
	regex = regex.replace("]", "\\]")
	regex = regex.replace("(", "\\(")
	regex = regex.replace(")", "\\)")
	regex = regex.replace("_", "%s([\\.A-Z_a-z\\[0-9\\]]*?)" % variable)

	re.compile(regex)
	for result in re.search_all(text):
		if result.get_string(1):
			# check if result is key in dictionary
			if "." in result.get_string(1):
				var parts = result.get_string(1).split(".")
				var key = parts[1]
				var _value = value[key]

				if parts.size() > 1:
					for i in range(2, parts.size()):
						key = parts[i]
						_value = _value[key]
					
				return output.replace(result.get_string(), _value)
			
			# check if result is index in array
			if "[" in result.get_string(1):
				if "]" in result.get_string(1):
					var parts = result.get_string(1).split("[")
					var index = int(parts[1].split("]")[0])
					var _value = value[index]

					if parts.size() > 1:
						for i in range(2, parts.size()):
							index = parts[i]
							_value = _value[index]
					
					return output.replace(result.get_string(), _value)

	return output

func replace_variables(text:String, variables:Dictionary, placeholder := "<_>") -> String:
	var output = "" + text

	for k in variables.keys():
		if variables[k] is Dictionary:
			output = parse_variable(output, placeholder, k, variables[k])

		if variables[k] is Array:
			output = parse_variable(output, placeholder, k, variables[k])

		if variables[k] is String:
			output = parse_variable(output, placeholder, k, variables[k])

		if variables[k] is Color:
			var var_text = placeholder.replace("_", k)
			output = output.replace(var_text, "#"+variables[k].to_html(false))
		
		if variables[k] is Resource:
			var var_text = placeholder.replace("_", k)
			output = output.replace(var_text, variables[k].get_path())

	output = output.format(variables, placeholder)

	return output