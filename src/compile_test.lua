#!/usr/bin/env lua

--[[

Bintest test compiler
Copyright (C) 2022  Rafael Carvalho

This file is part of Bintest

Bintest is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

--]]

local function die(str, code)
	if str ~= nil then io.stderr:write(str) end
	os.exit(code or 1)
end

local function file_exists(file_name)
	local f, err = io.open(file_name, "r")
	if f == nil then
		return false, err;
	else
		f:close();
		return true;
	end
end

local tests_config = nil
local tests_bin_name = arg[1]

if tests_bin_name == nil then
	die("Missing test binary name.\n")
end

local tests_config_file = arg[2]
if tests_config_file == nil then
	die("Missing tests config file name.\n")
else
	local ok, ret = pcall(require, tests_config_file)
	if not ok then
		die(string.format("Failed to open '%s' file: %s\n", tests_config_file, ret))
	else
		tests_config = ret;
	end
end

if tests_config.control_function_name ~= nil then
	if tests_config.control_function_file == nil then
		die("Config sets a control function but not its file.\n")
	else
		local ok, err = file_exists(tests_config.control_function_file)
		if not ok then
			die(string.format("Failed to open control function file '%s': %s\n", tests_config.control_function_file, err))
		end
	end
end

if tests_config.function_type == nil then
	die("Missing 'function_type' setting on config file.\n")
end

if tests_config.function_args == nil then
	die("Missing 'function_args' setting on config file.\n")
end

if tests_config.tests_cases_file == nil then
	die("Missing 'tests_cases_file' option on the config file.\n")
else
	local ok, err = file_exists(tests_config.tests_cases_file)
	if not ok then
		die(string.format("Failed to open tests cases file '%s': %s\n", tests_config.tests_cases_file, err))
	end
end

if tests_config.test_cases == nil then
	die("Missing 'test_cases' setting.\n")
elseif #tests_config.test_cases == 0 then
	die("No test cases were defined.\n")
end

local main_tmp_file = io.tmpfile()
if main_tmp_file == nil then
	die("Failed to create temporary file.\n")
end

if tests_config.tests_includes ~= nil then
	for include in pairs(tests_config.tests_includes) do
		main_tmp_file:write(string.format("#include <%s>\n", include))
	end
	main_tmp_file:write("\n")
end

for i, test in ipairs(tests_config.test_cases) do
	if test.name == nil or test.fun_name then
		io.stderr:write(string.format("Invalid test case at position %d\n", i))
		goto continue
	end

	::continue::
end

