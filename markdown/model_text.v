module markdown

pub struct Text{
pub mut:
	content string
}

fn (mut o Text) process()?{
	return
}

fn ( o Text) wiki() string{
	return o.content
	
}

fn ( o Text) html() string{
	return o.wiki()
}

fn ( o Text) str() string{
	return "**** Text\n"
}

