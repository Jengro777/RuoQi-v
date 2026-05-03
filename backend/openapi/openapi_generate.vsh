#!/usr/bin/env -S v run

module main

import os
import x.json2

const openapi_version = '3.0.3'

struct RouteBinding {
	module_path string
	base_path   string
	secure      bool
}

struct ApiResponseProfile {
	status_code string
	description string
}

struct StructDef {
	file_path      string
	module_path    string
	component_name string
	struct_name    string
	schema         map[string]json2.Any
}

struct StructBlock {
	struct_name string
	body        string
}

struct ResponseOverride {
	status_code string
	type_name   string
	description string
}

struct CommentMetadata {
mut:
	summary          string
	description      string
	tags             []string
	security         []string
	security_defined bool
	responses        []ResponseOverride
	has_example      bool
	example          json2.Any = json2.null
}

struct StructIndexes {
mut:
	struct_defs  map[string]StructDef
	file_index   map[string]map[string]StructDef
	global_index map[string][]StructDef
}

struct Operation {
	sub_path         string
	methods          []string
	function_name    string
	summary          string
	description      string
	tags             []string
	security         []string
	security_defined bool
	responses        []ResponseOverride
}

fn main() {
	script_dir := os.dir(os.real_path(@FILE))
	backend_dir := os.dir(script_dir)
	route_dir := os.join_path(backend_dir, 'route')
	service_dir := os.join_path(backend_dir, 'service')
	common_api_file := os.join_path(backend_dir, 'common', 'api', 'http_response.v')
	output_path := os.join_path(backend_dir, 'etc', 'openapi.json')

	route_bindings := parse_route_bindings(route_dir) or { panic(err) }
	indexes := parse_structs(service_dir, route_bindings) or { panic(err) }
	response_profiles := parse_api_response_profiles(common_api_file) or {
		map[string]ApiResponseProfile{}
	}
	paths, mut used_components := parse_operations(service_dir, route_bindings, indexes,
		response_profiles) or { panic(err) }
	components := build_components(indexes.struct_defs, mut used_components)

	mut info := map[string]json2.Any{}
	info['title'] = 'RuoQi-v API'
	info['version'] = '0.5.0'
	info['description'] = 'Generated from backend/route and backend/service source files.'

	sorted_info := sort_any(json2.Any(info))
	sorted_paths := sort_any(json2.Any(paths))
	sorted_components := sort_any(json2.Any(components))
	sorted_tags := sort_any(json2.Any(build_tags(paths)))

	mut spec := map[string]json2.Any{}
	spec['openapi'] = openapi_version
	spec['info'] = sorted_info
	spec['paths'] = sorted_paths
	spec['components'] = sorted_components
	spec['tags'] = sorted_tags

	content := json2.encode(json2.Any(spec), prettify: true)
	os.write_file(output_path, content + '\n') or { panic(err) }
}

fn parse_route_bindings(route_dir string) !map[string]RouteBinding {
	mut bindings := map[string]RouteBinding{}
	route_files := list_files_recursive(route_dir, '.v')!
	for route_file in route_files {
		text := os.read_file(route_file)!
		imports := parse_service_imports(text)
		mut pos := 0
		for {
			idx := find_from(text, 'register_routes_', pos) or { break }
			bracket_start := find_from(text, '[', idx) or { break }
			route_kind := text[idx + 'register_routes_'.len..bracket_start].trim_space()
			bracket_end := find_from(text, ']', bracket_start + 1) or {
				pos = bracket_start + 1
				continue
			}
			generic := text[bracket_start + 1..bracket_end].trim_space()
			controller_ref := generic.all_before(',').trim_space()
			quote1 := find_from(text, "'", bracket_end) or {
				pos = bracket_end + 1
				continue
			}
			quote2 := find_from(text, "'", quote1 + 1) or {
				pos = quote1 + 1
				continue
			}
			module_path := resolve_import_module(controller_ref, imports)
			if module_path.starts_with('service.') {
				bindings[module_path] = RouteBinding{
					module_path: module_path
					base_path:   normalize_path(text[quote1 + 1..quote2])
					secure:      route_kind == 'sys' || route_kind == 'core'
				}
			}
			pos = quote2 + 1
		}
	}
	return bindings
}

fn parse_service_imports(text string) map[string]string {
	mut imports := map[string]string{}
	for raw_line in text.split_into_lines() {
		line := raw_line.all_before('//').trim_space()
		if !line.starts_with('import service.') {
			continue
		}
		import_stmt := line.all_after('import ').trim_space()
		if import_stmt.contains(' as ') {
			parts := import_stmt.split(' as ')
			if parts.len == 2 {
				imports[parts[1].trim_space()] = parts[0].trim_space()
			}
			continue
		}
		if import_stmt.contains('{') && import_stmt.contains('}') {
			module_path := import_stmt.all_before('{').trim_space()
			names := import_stmt.all_after('{').all_before('}').split(',')
			for name in names {
				symbol := name.trim_space()
				if symbol != '' {
					imports[symbol] = module_path
				}
			}
			continue
		}
		module_path := import_stmt
		imports[module_path.all_after_last('.')] = module_path
	}
	return imports
}

fn resolve_import_module(controller_ref string, imports map[string]string) string {
	if controller_ref.contains('.') {
		alias := controller_ref.all_before('.').trim_space()
		return imports[alias] or { '' }
	}
	return imports[controller_ref] or { '' }
}

fn parse_structs(service_dir string, route_bindings map[string]RouteBinding) !StructIndexes {
	mut indexes := StructIndexes{
		struct_defs:  map[string]StructDef{}
		file_index:   map[string]map[string]StructDef{}
		global_index: map[string][]StructDef{}
	}

	service_files := list_files_recursive(service_dir, '.v')!
	for service_file in service_files {
		module_path := module_path_from_file(service_file, service_dir)
		if module_path !in route_bindings {
			continue
		}
		text := os.read_file(service_file)!
		mut schema_map := map[string]StructDef{}
		struct_blocks := find_struct_blocks(text)
		for block in struct_blocks {
			component_name := component_name_for(module_path, block.struct_name)
			struct_def := StructDef{
				file_path:      service_file
				module_path:    module_path
				component_name: component_name
				struct_name:    block.struct_name
				schema:         struct_body_to_schema(block.body, module_path, block.struct_name)
			}
			indexes.struct_defs[component_name] = struct_def
			schema_map[block.struct_name] = struct_def
			mut defs := indexes.global_index[block.struct_name] or { []StructDef{} }
			defs << struct_def
			indexes.global_index[block.struct_name] = defs
		}
		indexes.file_index[service_file] = schema_map.clone()
	}
	return indexes
}

fn parse_operations(service_dir string,
	route_bindings map[string]RouteBinding,
	indexes StructIndexes,
	response_profiles map[string]ApiResponseProfile) !(map[string]json2.Any, map[string]bool) {
	mut paths := map[string]json2.Any{}
	mut used_components := map[string]bool{}
	service_files := list_files_recursive(service_dir, '.v')!

	for service_file in service_files {
		module_path := module_path_from_file(service_file, service_dir)
		binding := route_bindings[module_path] or { continue }
		text := os.read_file(service_file)!
		operations := find_operations(text)
		if operations.len == 0 {
			continue
		}

		struct_map := (indexes.file_index[service_file] or {
			map[string]StructDef{}
		}).clone()
		request_type := find_request_type(text)
		response_type := find_response_type(text)
		success_status := find_success_status(text)
		used_response_codes := find_used_response_status_codes(text)
		tag_name := module_path.all_after('service.').replace('.', '/')
		request_component := resolve_component_name(request_type, struct_map, indexes.global_index)
		response_component := resolve_component_name(response_type, struct_map,
			indexes.global_index)
		if request_component != '' {
			used_components[request_component] = true
		}
		if response_component != '' {
			used_components[response_component] = true
		}

		for operation in operations {
			full_path := join_paths(binding.base_path, operation.sub_path)
			mut path_item := if full_path in paths {
				(paths[full_path] or { json2.Any(map[string]json2.Any{}) }).as_map()
			} else {
				map[string]json2.Any{}
			}
			for method in operation.methods {
				method_lower := method.to_lower()
				mut op_spec := map[string]json2.Any{}
				tag_values := if operation.tags.len > 0 { operation.tags.clone() } else { [
						tag_name,
					] }
				op_spec['tags'] = string_array_to_any(tag_values)
				op_spec['summary'] = if operation.summary != '' {
					operation.summary
				} else {
					operation.function_name
				}
				if operation.description != '' {
					op_spec['description'] = operation.description
				}
				op_spec['operationId'] = '${tag_name.replace('/', '_')}_${operation.function_name}_${method_lower}'
				op_spec['responses'] = build_responses(method_lower, success_status,
					response_component, response_type, mut used_components, binding.secure,
					operation.responses, used_response_codes, response_profiles, struct_map,
					indexes.global_index)
				if operation.security_defined {
					if operation.security.len > 0 {
						op_spec['security'] = build_security_requirement(operation.security)
					}
				} else if binding.secure {
					op_spec['security'] = build_security_requirement(['bearerAuth'])
				}
				if request_type != '' {
					if is_request_body_method(method_lower) {
						schema := schema_ref_or_inline(request_component, request_type, struct_map,
							indexes.global_index, mut used_components)
						if schema.len > 0 {
							op_spec['requestBody'] = build_request_body(schema)
						}
					} else if is_query_param_method(method_lower) {
						parameters := build_query_parameters(request_type, request_component,
							struct_map, indexes.global_index, mut used_components)
						if parameters.len > 0 {
							op_spec['parameters'] = parameters
						}
					}
				}
				path_item[method_lower] = op_spec
			}
			paths[full_path] = path_item
		}
	}

	return paths, used_components
}

fn list_files_recursive(root string, suffix string) ![]string {
	mut files := []string{}
	mut entries := os.ls(root)!
	entries.sort()
	for entry in entries {
		path := os.join_path(root, entry)
		if os.is_dir(path) {
			files << list_files_recursive(path, suffix)!
		} else if path.ends_with(suffix) {
			files << path
		}
	}
	return files
}

fn module_path_from_file(service_file string, service_dir string) string {
	rel := service_file[service_dir.len + 1..]
	rel_dir := os.dir(rel)
	if rel_dir == '.' {
		return 'service'
	}
	return 'service.' + rel_dir.replace('/', '.')
}

fn find_struct_blocks(text string) []StructBlock {
	mut blocks := []StructBlock{}
	mut pos := 0
	for {
		start := find_from(text, 'pub struct ', pos) or { break }
		name_start := start + 'pub struct '.len
		brace_start := find_from(text, '{', name_start) or { break }
		struct_name := text[name_start..brace_start].trim_space().all_before(' ').trim_space()
		brace_end := find_matching_brace(text, brace_start) or { break }
		blocks << StructBlock{
			struct_name: struct_name
			body:        text[brace_start + 1..brace_end]
		}
		pos = brace_end + 1
	}
	return blocks
}

fn find_matching_brace(text string, start int) ?int {
	mut depth := 0
	for i := start; i < text.len; i++ {
		if text[i] == `{` {
			depth++
		} else if text[i] == `}` {
			depth--
			if depth == 0 {
				return i
			}
		}
	}
	return none
}

fn struct_body_to_schema(body string, module_path string, _struct_name string) map[string]json2.Any {
	mut properties := map[string]json2.Any{}
	mut required_names := []string{}
	mut pending_comments := []string{}

	for raw_line in body.split_into_lines() {
		trimmed := raw_line.trim_space()
		if trimmed.starts_with('//') {
			pending_comments << trimmed.all_after('//').trim_space()
			continue
		}
		if trimmed == '' {
			pending_comments = []string{}
			continue
		}
		mut line := raw_line.all_before('//').trim_space()
		if line == '' || line == 'pub:' || line == 'mut:' {
			pending_comments = []string{}
			continue
		}
		if line.ends_with(':') {
			pending_comments = []string{}
			continue
		}
		json_name := extract_json_attr(line)
		line = strip_attributes(line).trim_space()
		if line == '' || line == 'pub:' || line == 'mut:' {
			pending_comments = []string{}
			continue
		}
		if line.contains('=') {
			line = line.all_before('=').trim_space()
		}
		if line == '' {
			pending_comments = []string{}
			continue
		}
		parts := line.fields()
		if parts.len < 2 {
			pending_comments = []string{}
			continue
		}
		field_name := parts[0]
		type_expr := parts[1..].join(' ').trim_space()
		property_name := if json_name != '' { json_name } else { field_name }
		mut field_schema, is_required := type_expr_to_schema(type_expr, module_path)
		field_doc := parse_comment_metadata(pending_comments)
		field_description := if field_doc.description != '' {
			field_doc.description
		} else {
			field_doc.summary
		}
		if field_description != '' {
			field_schema['description'] = field_description
		}
		if field_doc.has_example {
			field_schema['example'] = field_doc.example
		}
		properties[property_name] = field_schema
		if is_required {
			required_names << property_name
		}
		pending_comments = []string{}
	}

	mut schema := map[string]json2.Any{}
	schema['type'] = 'object'
	schema['properties'] = properties
	if required_names.len > 0 {
		schema['required'] = string_array_to_any(required_names)
	}
	return schema
}

fn extract_json_attr(line string) string {
	json_idx := line.index('json:') or { return '' }
	quote1 := find_from(line, "'", json_idx) or { return '' }
	quote2 := find_from(line, "'", quote1 + 1) or { return '' }
	return line[quote1 + 1..quote2]
}

fn strip_attributes(line string) string {
	mut result := line
	for {
		start := result.index('@[') or { break }
		end := find_from(result, ']', start + 2) or { break }
		result = result[..start] + result[end + 1..]
	}
	return result
}

fn type_expr_to_schema(type_expr string, module_path string) (map[string]json2.Any, bool) {
	mut expr := type_expr.trim_space()
	mut required := true
	mut nullable := false
	if expr.starts_with('?') {
		required = false
		nullable = true
		expr = expr[1..].trim_space()
	}

	mut schema := map[string]json2.Any{}
	if expr.starts_with('[]') {
		items_schema, _ := type_expr_to_schema(expr[2..].trim_space(), module_path)
		schema['type'] = 'array'
		schema['items'] = items_schema
	} else if expr.starts_with('map[') {
		schema['type'] = 'object'
		close_idx := expr.index(']') or { -1 }
		if close_idx >= 0 && close_idx + 1 < expr.len {
			value_expr := expr[close_idx + 1..].trim_space()
			if value_expr != '' {
				value_schema, _ := type_expr_to_schema(value_expr, module_path)
				schema['additionalProperties'] = value_schema
			} else {
				schema['additionalProperties'] = true
			}
		} else {
			schema['additionalProperties'] = true
		}
	} else if int_format := integer_format(expr) {
		schema['type'] = 'integer'
		schema['format'] = int_format
	} else if number_format := numeric_format(expr) {
		schema['type'] = 'number'
		schema['format'] = number_format
	} else if expr == 'string' {
		schema['type'] = 'string'
	} else if expr == 'bool' {
		schema['type'] = 'boolean'
	} else if expr == 'time.Time' || expr == 'Time' {
		schema['type'] = 'string'
		schema['format'] = 'date-time'
	} else if expr == 'json2.Any' || expr == 'Any' {
		schema['type'] = 'object'
	} else {
		ref_name := expr.all_after_last('.')
		schema = schema_ref(component_name_for(module_path, ref_name))
	}

	if nullable {
		schema['nullable'] = true
	}
	return schema, required
}

fn integer_format(expr string) ?string {
	return match expr {
		'int', 'i8', 'i16', 'i32', 'u8', 'u16' { 'int32' }
		'i64', 'u32', 'u64' { 'int64' }
		else { none }
	}
}

fn numeric_format(expr string) ?string {
	return match expr {
		'f32' { 'float' }
		'f64' { 'double' }
		else { none }
	}
}

fn find_operations(text string) []Operation {
	mut operations := []Operation{}
	mut pending_comments := []string{}
	mut current_attr := ''
	mut current_comments := []string{}
	for raw_line in text.split_into_lines() {
		line := raw_line.trim_space()
		if line.starts_with('//') {
			pending_comments << line.all_after('//').trim_space()
			continue
		}
		if line == '' {
			if current_attr == '' {
				pending_comments = []string{}
			}
			continue
		}
		if line.starts_with("@['") && line.contains(']') {
			current_attr = line
			current_comments = pending_comments.clone()
			pending_comments = []string{}
			continue
		}
		if current_attr != '' && line.contains('fn ') {
			sub_path, methods := parse_route_attrs(current_attr)
			function_name := parse_function_name(line)
			doc_meta := parse_comment_metadata(current_comments)
			if sub_path != '' && methods.len > 0 && function_name != '' {
				operations << Operation{
					sub_path:         sub_path
					methods:          methods
					function_name:    function_name
					summary:          doc_meta.summary
					description:      doc_meta.description
					tags:             doc_meta.tags.clone()
					security:         doc_meta.security.clone()
					security_defined: doc_meta.security_defined
					responses:        doc_meta.responses.clone()
				}
			}
			current_attr = ''
			current_comments = []string{}
			pending_comments = []string{}
			continue
		}
		if current_attr == '' {
			pending_comments = []string{}
		}
	}
	return operations
}

fn parse_comment_metadata(comment_lines []string) CommentMetadata {
	mut meta := CommentMetadata{}
	mut plain_lines := []string{}
	mut description_lines := []string{}

	for raw_line in comment_lines {
		line := raw_line.trim_space()
		if line == '' || is_decorative_comment(line) {
			continue
		}
		if value := extract_tag_value(line, '@summary') {
			meta.summary = value
			continue
		}
		if value := extract_tag_value(line, '@description') {
			description_lines << value
			continue
		}
		if value := extract_tag_value(line, '@tag') {
			append_unique(mut meta.tags, value)
			continue
		}
		if value := extract_tag_value(line, '@security') {
			meta.security_defined = true
			for item in parse_security_values(value) {
				append_unique(mut meta.security, item)
			}
			continue
		}
		if value := extract_tag_value(line, '@response') {
			if response := parse_response_override(value) {
				meta.responses << response
			}
			continue
		}
		if value := extract_tag_value(line, '@example') {
			meta.example = parse_example_value(value)
			meta.has_example = true
			continue
		}
		if line.starts_with('@') {
			continue
		}
		plain_lines << line
	}

	if meta.summary == '' && plain_lines.len > 0 {
		meta.summary = plain_lines[0]
	}
	if description_lines.len > 0 {
		meta.description = description_lines.join('\n')
	} else if plain_lines.len > 0 {
		if meta.summary == plain_lines[0] {
			if plain_lines.len > 1 {
				meta.description = plain_lines[1..].join('\n')
			}
		} else {
			meta.description = plain_lines.join('\n')
		}
	}
	return meta
}

fn extract_tag_value(line string, tag string) ?string {
	if !line.starts_with(tag) {
		return none
	}
	if line.len == tag.len {
		return ''
	}
	next_char := line[tag.len]
	if next_char != ` ` && next_char != `\t` {
		return none
	}
	return line[tag.len..].trim_space()
}

fn parse_security_values(value string) []string {
	normalized := value.replace(',', ' ')
	mut items := []string{}
	for item in normalized.fields() {
		scheme := item.trim_space()
		if scheme == '' || scheme.to_lower() == 'none' {
			continue
		}
		items << scheme
	}
	return items
}

fn parse_response_override(value string) ?ResponseOverride {
	parts := value.fields()
	if parts.len < 2 {
		return none
	}
	status_code := parts[0]
	type_name := parts[1]
	description := value.all_after(status_code).trim_space().all_after(type_name).trim_space()
	return ResponseOverride{
		status_code: status_code
		type_name:   type_name
		description: description
	}
}

fn parse_example_value(value string) json2.Any {
	trimmed := value.trim_space()
	if trimmed == '' {
		return json2.null
	}
	parsed := json2.decode[json2.Any](trimmed) or { return json2.Any(trimmed) }
	return parsed
}

fn is_decorative_comment(line string) bool {
	return line.contains('---') || line.contains('===')
}

fn append_unique(mut items []string, value string) {
	if value == '' || value in items {
		return
	}
	items << value
}

fn parse_route_attrs(attr_line string) (string, []string) {
	content := attr_line.all_after('@[').all_before_last(']')
	mut methods := []string{}
	mut method_set := map[string]bool{}
	mut sub_path := ''
	for raw_token in content.split(';') {
		token := raw_token.trim_space()
		if token.len >= 2 && token.starts_with("'") && token.ends_with("'") {
			sub_path = token[1..token.len - 1]
			continue
		}
		method := token.to_lower()
		if is_http_method(method) && method !in method_set {
			method_set[method] = true
			methods << method
		}
	}
	return sub_path, methods
}

fn parse_function_name(line string) string {
	mut content := line.trim_space()
	if content.starts_with('pub ') {
		content = content[4..].trim_space()
	}
	if !content.starts_with('fn ') {
		return ''
	}
	content = content[3..].trim_space()
	if content.starts_with('(') {
		receiver_end := find_from(content, ')', 1) or { return '' }
		content = content[receiver_end + 1..].trim_space()
	}
	return content.all_before('(').trim_space()
}

fn find_request_type(text string) string {
	start := text.index('json.decode[') or { return '' }
	type_start := start + 'json.decode['.len
	type_end := find_from(text, ']', type_start) or { return '' }
	return text[type_start..type_end].trim_space()
}

fn find_response_type(text string) string {
	for raw_line in text.split_into_lines() {
		line := raw_line.trim_space()
		if !line.starts_with('pub fn ') || !line.contains('_usecase') {
			continue
		}
		after := line.all_after_last(')').trim_space()
		if after.starts_with('!') {
			return after[1..].all_before('{').trim_space()
		}
	}

	if text.contains("json_success_200('") || text.contains("json_success_201('")
		|| text.contains("json_success_202('")
		|| (text.contains('json_success(') && text.contains("data: '")) {
		return 'string'
	}
	return ''
}

fn find_success_status(text string) int {
	idx := text.index('json_success_') or { -1 }
	if idx >= 0 {
		start := idx + 'json_success_'.len
		mut end := start
		for end < text.len && text[end] >= `0` && text[end] <= `9` {
			end++
		}
		if end > start {
			return text[start..end].int()
		}
	}

	status_idx := text.index('status:') or { -1 }
	if status_idx >= 0 {
		mut start := status_idx + 'status:'.len
		for start < text.len && text[start].is_space() {
			start++
		}
		mut end := start
		for end < text.len && text[end] >= `0` && text[end] <= `9` {
			end++
		}
		if end > start {
			return text[start..end].int()
		}
	}
	return 200
}

fn find_used_response_status_codes(text string) []string {
	mut status_set := map[string]bool{}
	for prefix in ['json_success_', 'json_error_'] {
		mut pos := 0
		for {
			idx := find_from(text, prefix, pos) or { break }
			mut start := idx + prefix.len
			mut end := start
			for end < text.len && text[end] >= `0` && text[end] <= `9` {
				end++
			}
			if end > start {
				status_set[text[start..end]] = true
			}
			pos = end + 1
		}
	}
	mut statuses := status_set.keys()
	statuses.sort()
	return statuses
}

fn resolve_component_name(type_name string,
	file_structs map[string]StructDef,
	global_index map[string][]StructDef) string {
	if type_name == '' || type_name == 'string' {
		return ''
	}
	if type_name in file_structs {
		return file_structs[type_name].component_name
	}
	matches := global_index[type_name] or { []StructDef{} }
	if matches.len == 1 {
		return matches[0].component_name
	}
	return ''
}

fn schema_ref_or_inline(component_name string,
	type_name string,
	file_structs map[string]StructDef,
	global_index map[string][]StructDef,
	mut used_components map[string]bool) map[string]json2.Any {
	if component_name != '' {
		used_components[component_name] = true
		return schema_ref(component_name)
	}
	if type_name == 'string' {
		return string_schema()
	}
	if type_name in file_structs {
		return file_structs[type_name].schema.clone()
	}
	matches := global_index[type_name] or { []StructDef{} }
	if matches.len == 1 {
		used_components[matches[0].component_name] = true
		return schema_ref(matches[0].component_name)
	}
	return object_schema()
}

fn build_query_parameters(type_name string,
	component_name string,
	file_structs map[string]StructDef,
	global_index map[string][]StructDef,
	mut used_components map[string]bool) []json2.Any {
	mut source_schema := map[string]json2.Any{}
	if component_name != '' {
		used_components[component_name] = true
		if type_name in file_structs {
			source_schema = file_structs[type_name].schema.clone()
		} else {
			matches := global_index[type_name] or { []StructDef{} }
			if matches.len == 1 {
				source_schema = matches[0].schema.clone()
			}
		}
	} else if type_name in file_structs {
		source_schema = file_structs[type_name].schema.clone()
	} else {
		matches := global_index[type_name] or { []StructDef{} }
		if matches.len == 1 {
			source_schema = matches[0].schema.clone()
			used_components[matches[0].component_name] = true
		}
	}

	if source_schema.len == 0 || 'properties' !in source_schema {
		return []json2.Any{}
	}

	properties := (source_schema['properties'] or { json2.Any(map[string]json2.Any{}) }).as_map()
	mut required_set := map[string]bool{}
	if 'required' in source_schema {
		for item in (source_schema['required'] or { json2.Any([]json2.Any{}) }).as_array() {
			required_set[item.str()] = true
		}
	}

	mut keys := properties.keys()
	keys.sort()
	mut parameters := []json2.Any{}
	for key in keys {
		mut parameter := map[string]json2.Any{}
		parameter['in'] = 'query'
		parameter['name'] = key
		parameter['required'] = key in required_set
		parameter['schema'] = properties[key] or { json2.Any(object_schema()) }
		parameters << parameter
	}
	return parameters
}

fn build_responses(method string,
	success_status int,
	response_component string,
	response_type string,
	mut used_components map[string]bool,
	secured bool,
	response_overrides []ResponseOverride,
	used_response_codes []string,
	response_profiles map[string]ApiResponseProfile,
	file_structs map[string]StructDef,
	global_index map[string][]StructDef) map[string]json2.Any {
	success_wrapper := ensure_success_wrapper(response_component, response_type, mut
		used_components)
	mut responses := map[string]json2.Any{}
	responses[success_status.str()] = response_entry(default_response_description(success_status.str(),
		response_profiles), success_wrapper)
	responses['400'] = error_response(default_response_description('400', response_profiles), mut
		used_components)
	responses['500'] = error_response(default_response_description('500', response_profiles), mut
		used_components)
	if method != 'get' && method != 'head' {
		responses['422'] = error_response(default_response_description('422', response_profiles), mut
			used_components)
	}
	if secured {
		responses['401'] = error_response(default_response_description('401', response_profiles), mut
			used_components)
		responses['403'] = error_response(default_response_description('403', response_profiles), mut
			used_components)
	}
	for status_code in used_response_codes {
		if status_code.starts_with('2') || status_code in responses {
			continue
		}
		responses[status_code] = error_response(default_response_description(status_code,
			response_profiles), mut used_components)
	}
	for override in response_overrides {
		responses[override.status_code] = response_entry_for_override(override, file_structs,
			global_index, mut used_components, response_profiles)
	}
	return responses
}

fn ensure_success_wrapper(response_component string,
	response_type string,
	mut used_components map[string]bool) string {
	wrapper_name := if response_type == 'string' {
		'ApiSuccessResponse_string'
	} else if response_component != '' {
		'ApiSuccessResponse_${response_component}'
	} else {
		'ApiSuccessResponse_object'
	}
	used_components[wrapper_name] = true
	return wrapper_name
}

fn build_request_body(schema map[string]json2.Any) map[string]json2.Any {
	mut content_item := map[string]json2.Any{}
	content_item['schema'] = schema

	mut content := map[string]json2.Any{}
	content['application/json'] = content_item

	mut request_body := map[string]json2.Any{}
	request_body['required'] = true
	request_body['content'] = content
	return request_body
}

fn response_entry(description string, schema_name string) map[string]json2.Any {
	mut schema_item := map[string]json2.Any{}
	schema_item['schema'] = schema_ref(schema_name)

	mut content := map[string]json2.Any{}
	content['application/json'] = schema_item

	mut response := map[string]json2.Any{}
	response['description'] = description
	response['content'] = content
	return response
}

fn error_response(description string, mut used_components map[string]bool) map[string]json2.Any {
	used_components['ApiErrorResponse'] = true
	return response_entry(description, 'ApiErrorResponse')
}

fn response_entry_for_override(override ResponseOverride,
	file_structs map[string]StructDef,
	global_index map[string][]StructDef,
	mut used_components map[string]bool,
	response_profiles map[string]ApiResponseProfile) map[string]json2.Any {
	description := if override.description != '' {
		override.description
	} else {
		default_response_description(override.status_code, response_profiles)
	}
	schema := response_schema_for_override(override.status_code, override.type_name, file_structs,
		global_index, mut used_components)
	if schema.len == 0 {
		mut response := map[string]json2.Any{}
		response['description'] = description
		return response
	}
	return response_entry_with_schema(description, schema)
}

fn response_schema_for_override(status_code string,
	type_name string,
	file_structs map[string]StructDef,
	global_index map[string][]StructDef,
	mut used_components map[string]bool) map[string]json2.Any {
	normalized_type := type_name.trim_space()
	if normalized_type == '' || normalized_type == '-' || normalized_type.to_lower() == 'none' {
		return map[string]json2.Any{}
	}
	if normalized_type.starts_with('ApiSuccessResponse_') {
		used_components[normalized_type] = true
		return schema_ref(normalized_type)
	}
	if status_code.starts_with('2') {
		wrapper_name := ensure_success_wrapper_for_type(normalized_type, file_structs,
			global_index, mut used_components)
		return schema_ref(wrapper_name)
	}
	return schema_for_annotation_type(normalized_type, file_structs, global_index, mut
		used_components)
}

fn ensure_success_wrapper_for_type(type_name string,
	file_structs map[string]StructDef,
	global_index map[string][]StructDef,
	mut used_components map[string]bool) string {
	if type_name == 'string' {
		used_components['ApiSuccessResponse_string'] = true
		return 'ApiSuccessResponse_string'
	}
	if type_name == 'object' || type_name == 'json2.Any' || type_name == 'Any' {
		used_components['ApiSuccessResponse_object'] = true
		return 'ApiSuccessResponse_object'
	}
	if component_name := resolve_annotation_component_name(type_name, file_structs, global_index) {
		return ensure_success_wrapper(component_name, '', mut used_components)
	}
	used_components['ApiSuccessResponse_object'] = true
	return 'ApiSuccessResponse_object'
}

fn schema_for_annotation_type(type_name string,
	file_structs map[string]StructDef,
	global_index map[string][]StructDef,
	mut used_components map[string]bool) map[string]json2.Any {
	normalized_type := type_name.trim_space()
	if normalized_type.starts_with('[]') {
		mut schema := map[string]json2.Any{}
		schema['type'] = 'array'
		schema['items'] = schema_for_annotation_type(normalized_type[2..].trim_space(),
			file_structs, global_index, mut used_components)
		return schema
	}
	match normalized_type {
		'string' {
			return string_schema()
		}
		'object', 'json2.Any', 'Any' {
			return object_schema()
		}
		'ApiErrorResponse', 'api.ApiErrorResponse' {
			used_components['ApiErrorResponse'] = true
			return schema_ref('ApiErrorResponse')
		}
		'ValidationError', 'api.ValidationError' {
			used_components['ValidationError'] = true
			return schema_ref('ValidationError')
		}
		else {}
	}

	if component_name := resolve_annotation_component_name(normalized_type, file_structs,
		global_index)
	{
		used_components[component_name] = true
		return schema_ref(component_name)
	}
	return object_schema()
}

fn resolve_annotation_component_name(type_name string,
	file_structs map[string]StructDef,
	global_index map[string][]StructDef) ?string {
	component_name := resolve_component_name(type_name, file_structs, global_index)
	if component_name != '' {
		return component_name
	}
	if type_name.contains('.') {
		component_name_by_short_name := resolve_component_name(type_name.all_after_last('.'),
			file_structs, global_index)
		if component_name_by_short_name != '' {
			return component_name_by_short_name
		}
	}
	return none
}

fn response_entry_with_schema(description string, schema map[string]json2.Any) map[string]json2.Any {
	mut schema_item := map[string]json2.Any{}
	schema_item['schema'] = schema

	mut content := map[string]json2.Any{}
	content['application/json'] = schema_item

	mut response := map[string]json2.Any{}
	response['description'] = description
	response['content'] = content
	return response
}

fn parse_api_response_profiles(file_path string) !map[string]ApiResponseProfile {
	mut profiles := map[string]ApiResponseProfile{}
	text := os.read_file(file_path)!
	mut pending_comments := []string{}
	for raw_line in text.split_into_lines() {
		line := raw_line.trim_space()
		if line.starts_with('//') {
			pending_comments << line.all_after('//').trim_space()
			continue
		}
		if line == '' {
			continue
		}
		if line.starts_with('pub fn ') {
			function_name := line.all_after('pub fn ').all_before('(').all_before('[').trim_space()
			if status_code := status_code_from_response_helper(function_name) {
				description := comment_lines_to_description(pending_comments)
				profiles[status_code] = ApiResponseProfile{
					status_code: status_code
					description: if description != '' {
						description
					} else {
						default_response_description_fallback(status_code)
					}
				}
			}
		}
		pending_comments = []string{}
	}
	return profiles
}

fn status_code_from_response_helper(function_name string) ?string {
	for prefix in ['json_success_', 'json_error_'] {
		if !function_name.starts_with(prefix) {
			continue
		}
		mut start := prefix.len
		mut end := start
		for end < function_name.len && function_name[end] >= `0` && function_name[end] <= `9` {
			end++
		}
		if end > start {
			return function_name[start..end]
		}
	}
	return none
}

fn comment_lines_to_description(lines []string) string {
	mut items := []string{}
	for line in lines {
		trimmed := line.trim_space()
		if trimmed == '' || is_decorative_comment(trimmed) {
			continue
		}
		items << normalize_response_comment_line(trimmed)
	}
	return items.join(' ')
}

fn normalize_response_comment_line(line string) string {
	if line.len > 0 && line[0] >= `0` && line[0] <= `9` && line.contains(' - ') {
		return line.all_after_last(' - ').trim_space()
	}
	return line
}

fn default_response_description(status_code string, response_profiles map[string]ApiResponseProfile) string {
	if profile := response_profiles[status_code] {
		return profile.description
	}
	return default_response_description_fallback(status_code)
}

fn default_response_description_fallback(status_code string) string {
	return match status_code {
		'200' { 'Successful response' }
		'201' { 'Created' }
		'202' { 'Accepted' }
		'204' { 'No Content' }
		'400' { 'Bad Request' }
		'401' { 'Unauthorized' }
		'403' { 'Forbidden' }
		'404' { 'Not Found' }
		'422' { 'Unprocessable Entity' }
		'500' { 'Internal Server Error' }
		else { 'Response' }
	}
}

fn build_security_requirement(schemes []string) []json2.Any {
	mut security_item := map[string]json2.Any{}
	for scheme in schemes {
		security_item[scheme] = []json2.Any{}
	}
	return [json2.Any(security_item)]
}

fn build_components(struct_defs map[string]StructDef, mut used_components map[string]bool) map[string]json2.Any {
	mut schemas := map[string]json2.Any{}
	schemas['ValidationError'] = build_validation_error_schema()
	schemas['ApiErrorResponse'] = build_api_error_response_schema()
	schemas['ApiSuccessResponse_string'] = success_wrapper_schema(string_schema())
	schemas['ApiSuccessResponse_object'] = success_wrapper_schema(object_schema())

	mut queue := used_components.keys()
	queue.sort()
	mut processed := map[string]bool{}

	for queue.len > 0 {
		name := queue[0]
		queue.delete(0)
		if name in processed {
			continue
		}
		processed[name] = true

		if name.starts_with('ApiSuccessResponse_') {
			if name !in schemas {
				data_name := name.all_after('ApiSuccessResponse_')
				if data_name == 'string' {
					schemas[name] = success_wrapper_schema(string_schema())
				} else if data_name == 'object' {
					schemas[name] = success_wrapper_schema(object_schema())
				} else if data_name in struct_defs {
					schemas[name] = success_wrapper_schema(schema_ref(data_name))
					if data_name !in processed {
						queue << data_name
					}
				} else {
					schemas[name] = success_wrapper_schema(object_schema())
				}
			}
			for ref in collect_schema_refs((schemas[name] or { json2.Any(map[string]json2.Any{}) }).as_map()) {
				if ref in struct_defs && ref !in processed {
					queue << ref
				}
			}
			continue
		}

		if name in struct_defs {
			schemas[name] = struct_defs[name].schema.clone()
			for ref in collect_schema_refs(struct_defs[name].schema.clone()) {
				if ref in struct_defs && ref !in processed {
					queue << ref
				}
			}
		}
	}

	mut security_schemes := map[string]json2.Any{}
	mut bearer_auth := map[string]json2.Any{}
	bearer_auth['type'] = 'http'
	bearer_auth['scheme'] = 'bearer'
	bearer_auth['bearerFormat'] = 'JWT'
	security_schemes['bearerAuth'] = bearer_auth

	mut components := map[string]json2.Any{}
	components['securitySchemes'] = security_schemes
	components['schemas'] = schemas
	return components
}

fn build_validation_error_schema() map[string]json2.Any {
	mut properties := map[string]json2.Any{}
	properties['field'] = string_schema()
	properties['msg'] = string_schema()
	properties['rule'] = string_schema()

	mut meta_schema := object_schema()
	meta_schema['additionalProperties'] = string_schema()
	properties['meta'] = meta_schema

	mut schema := object_schema()
	schema['properties'] = properties
	schema['required'] = string_array_to_any(['field', 'msg', 'rule', 'meta'])
	return schema
}

fn build_api_error_response_schema() map[string]json2.Any {
	mut properties := map[string]json2.Any{}
	properties['code'] = integer_schema('int32')
	properties['status'] = integer_schema('int32')
	properties['request_id'] = string_schema()
	properties['error'] = string_schema()

	mut details_schema := map[string]json2.Any{}
	details_schema['type'] = 'array'
	details_schema['nullable'] = true
	details_schema['items'] = schema_ref('ValidationError')
	properties['details'] = details_schema

	mut schema := object_schema()
	schema['properties'] = properties
	schema['required'] = string_array_to_any(['code', 'status', 'request_id', 'error'])
	return schema
}

fn success_wrapper_schema(data_schema map[string]json2.Any) map[string]json2.Any {
	mut properties := map[string]json2.Any{}
	properties['code'] = integer_schema('int32')
	properties['status'] = integer_schema('int32')
	properties['request_id'] = string_schema()
	properties['data'] = data_schema

	mut msg_schema := string_schema()
	msg_schema['nullable'] = true
	properties['msg'] = msg_schema

	mut schema := object_schema()
	schema['properties'] = properties
	schema['required'] = string_array_to_any(['code', 'status', 'request_id', 'data'])
	return schema
}

fn collect_schema_refs(schema map[string]json2.Any) []string {
	mut refs := map[string]bool{}
	collect_refs_from_any(json2.Any(schema), mut refs)
	mut names := refs.keys()
	names.sort()
	return names
}

fn collect_refs_from_any(value json2.Any, mut refs map[string]bool) {
	match value {
		map[string]json2.Any {
			if '\$ref' in value {
				ref_name := (value['\$ref'] or { json2.Any('') }).str().all_after_last('/')
				if ref_name != '' {
					refs[ref_name] = true
				}
			}
			for _, nested in value {
				collect_refs_from_any(nested, mut refs)
			}
		}
		[]json2.Any {
			for nested in value {
				collect_refs_from_any(nested, mut refs)
			}
		}
		else {}
	}
}

fn build_tags(paths map[string]json2.Any) []json2.Any {
	mut tag_set := map[string]bool{}
	for _, path_item_any in paths {
		path_item := path_item_any.as_map()
		for _, operation_any in path_item {
			operation := operation_any.as_map()
			if 'tags' !in operation {
				continue
			}
			for tag in (operation['tags'] or { json2.Any([]json2.Any{}) }).as_array() {
				tag_set[tag.str()] = true
			}
		}
	}

	mut tag_names := tag_set.keys()
	tag_names.sort()
	mut tags := []json2.Any{}
	for tag_name in tag_names {
		mut tag := map[string]json2.Any{}
		tag['name'] = tag_name
		tags << tag
	}
	return tags
}

fn sort_any(value json2.Any) json2.Any {
	match value {
		map[string]json2.Any {
			mut keys := value.keys()
			keys.sort()
			mut out := map[string]json2.Any{}
			for key in keys {
				out[key] = sort_any(value[key] or { json2.Any('') })
			}
			return out
		}
		[]json2.Any {
			mut out := []json2.Any{cap: value.len}
			for item in value {
				out << sort_any(item)
			}
			return out
		}
		else {
			return value
		}
	}
}

fn string_array_to_any(values []string) []json2.Any {
	mut result := []json2.Any{cap: values.len}
	for value in values {
		result << value
	}
	return result
}

fn schema_ref(name string) map[string]json2.Any {
	mut schema := map[string]json2.Any{}
	schema['\$ref'] = '#/components/schemas/${name}'
	return schema
}

fn object_schema() map[string]json2.Any {
	mut schema := map[string]json2.Any{}
	schema['type'] = 'object'
	return schema
}

fn string_schema() map[string]json2.Any {
	mut schema := map[string]json2.Any{}
	schema['type'] = 'string'
	return schema
}

fn integer_schema(format string) map[string]json2.Any {
	mut schema := map[string]json2.Any{}
	schema['type'] = 'integer'
	schema['format'] = format
	return schema
}

fn component_name_for(module_path string, struct_name string) string {
	return module_path.all_after('service.').replace('.', '_') + '_' + struct_name
}

fn join_paths(base_path string, sub_path string) string {
	if sub_path == '/' {
		return normalize_path(base_path)
	}
	return normalize_path(base_path.trim_right('/') + '/' + sub_path.trim_left('/'))
}

fn normalize_path(path string) string {
	mut normalized := path.trim_space()
	for normalized.contains('//') {
		normalized = normalized.replace('//', '/')
	}
	if !normalized.starts_with('/') {
		normalized = '/' + normalized
	}
	if normalized != '/' && normalized.ends_with('/') {
		normalized = normalized[..normalized.len - 1]
	}
	return normalized
}

fn is_http_method(method string) bool {
	return method == 'get' || method == 'post' || method == 'put' || method == 'patch'
		|| method == 'delete' || method == 'options' || method == 'head'
}

fn is_request_body_method(method string) bool {
	return method == 'post' || method == 'put' || method == 'patch'
}

fn is_query_param_method(method string) bool {
	return method == 'get' || method == 'delete' || method == 'head'
}

fn find_from(text string, needle string, start int) ?int {
	if start >= text.len {
		return none
	}
	idx := text[start..].index(needle) or { return none }
	return start + idx
}
