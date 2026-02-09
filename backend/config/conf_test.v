module config

fn test_config_toml() {
	dump(config_toml())
	assert config_toml().len == 0
}

fn test_read_toml() {
	doc_toml := read_toml() or { panic(err) }
	dump(doc_toml)
	// assert !isnil(doc_toml.ast.table)
}

fn test_parse_data() {
	global_config := parse_data() or { panic(err) }
	dump(global_config)
}
