module texttools

//check the char is in a...Z0..9
fn is_var_char(char string) bool{
	if 'abcdefghijklmnopqrstuvwxyz0123456789_-'.contains(char.to_lower()){
		return true
	} 
	return false
}

// the map has as key the normalized string (fix_name_no_underscore), the value is what to replace with
pub fn replace_items(text string, replacer map[string]string) string {
	mut skipline := false
	mut res := []string{}
	mut keys := []string{}
	mut var := ""
	mut char := ""
	toskip := "/.|:'`"
	// mut done := []string{}

	mut replacer2 :=  map[string]string{}

	for key, _ in replacer {
		keys << key
	}

	for key in keys {
		key2 := texttools.name_fix_no_underscore_token(key)
		replacer2[key2] = replacer[key]
	}

	text_lines := text.split('\n')

	for line in text_lines {
		//println(" - '$line'")
		if line.trim(' ').starts_with('!') {
			res << line
			continue
		}
		if line.trim(' ').starts_with('|') {
			res << line
			continue
		}		
		if line.trim(' ').starts_with('/') {
			res << line
			continue
		}
		if line.trim(' ').starts_with('#') {
			res << line
			continue
		}
		if line.trim(' ').starts_with('<!-') {
			res << line
			continue
		}
		
		if line.contains("'''") || line.contains('```') || line.contains('"""') {
			skipline = !skipline
		}
		if skipline {
			res << line
			continue
		}

		var = ""
		mut prevchar := ""
		mut is_comment := false
		mut is_possible_link := false
		mut is_link := false
		mut line_out := ""
		mut var_skip := false
		for char_ in line.split('') {
			char = char_

			if toskip.contains(char){
				//this means that the next var cannot be used
				var_skip = true
			}
			if char == "["{
				//println(" ++++ is_possible_link")
				is_possible_link = true
			}
			if prevchar=="]" && char=="(" && is_possible_link{
				//println(" ++++ islink")
				is_link = true
			}
			//end of link
			if char==")" && is_link{
				is_link = false
				is_possible_link = false
				line_out += char
				//println("++++ end link")
				prevchar = char
				char = ""
				continue
			}
			if is_possible_link || is_link  || is_comment {
				line_out += char
				prevchar = char
				continue
			}
			//println(" -- char:'$char'")
			if is_var_char(char){
				if var_skip{
					line_out += char
					prevchar = char
					char = ""
					continue					
				}else{
					var+=char
					//println(" -- var:'$var'")
				}
			}else{				
				//means we have potentially found a var, now char not part of var
				//println(" -- varsubst:${varsubst(char, var, replacer2)}")
				line_out += varsubst(char, var, replacer2)
				var = ""
				if ! toskip.contains(char){
					var_skip = false
				}				
			}
			prevchar = char
			char = ""
		}
		//println(" --- endline: lastchar:'$char' varsubst:${varsubst(char, var, replacer2)}")
		line_out += varsubst(char, var, replacer2)
		//println(" -> ${line_out}")
		res << line_out
	}
	final_res := res.join('\n')	

	return final_res
}

fn varsubst(char string, var string, replacer map[string]string )string {
	if var.len>0{
		//yes we found a var
		var2 := texttools.name_fix_no_underscore_token(var)
		if var2 in replacer{
			return replacer[var2]+char
		}
		return var+char
	}else{
		return char
	}
}