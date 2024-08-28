import os
import re

if not os.path.exists("build"):
    os.mkdir('build')


def read_file(path: str, encoding: str = 'utf-8') -> str:
    with open(path, 'r', encoding=encoding) as f:
        return f.read()


FIND_REQUIRE_RE = re.compile("""(require ['"](.*?)['"])""")


def read_module_lua(module: str) -> str:
    base_path = module.replace('.', '/')
    path_options = [
        base_path + '.lua',
        base_path + '/init.lua'
    ]
    for path in path_options:
        if os.path.exists(path):
            return read_file(path)
    raise Exception(f"Not found module '{module}' from: [{', '.join(path_options)}]")


def parse_module(module: str):
    code = read_module_lua(module)
    find = FIND_REQUIRE_RE.findall(code)
    for source_code, module_name in find:
        code = code.replace(source_code, f'__BUILDED_MODULE__.REQUIRE("{module_name}")')
    print(code)


if __name__ == '__main__':
    parse_module("rkgui")
