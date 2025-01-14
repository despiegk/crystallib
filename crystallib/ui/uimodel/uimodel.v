module uimodel

@[params]
pub struct DropDownArgs {
pub mut:
	description    string
	question       string
	items          []string
	default        []string
	warning        string
	clear          bool
	all            bool
	choice_message string
	validation     fn (string) bool = fn (s string) bool {
		return true
	}
}

@[params]
pub struct QuestionArgs {
pub mut:
	description string
	question    string
	warning     string
	clear       bool
	regex       string
	minlen      int
	reset       bool
	default     string
	validation  fn (string) bool = fn (s string) bool {
		return true
	}
}

// validation responds with either true or an error message

@[params]
pub struct YesNoArgs {
pub mut:
	description string
	question    string
	warning     string
	clear       bool
	reset       bool
	default     bool
	validation  fn (string) bool = fn (s string) bool {
		return true
	}
}
