import os
import re

FIND_REQUIRE_RE = re.compile("""(require ['"](.*?)['"])""")

if not os.path.exists("build"):
    os.mkdir('build')


def read_file(path: str, encoding: str = 'utf-8') -> str:
    with open(path, 'r', encoding=encoding) as f:
        return f.read()


def build(main_file_path: str):
    code = read_file(main_file_path)
    find = FIND_REQUIRE_RE.findall(code)
    for source_code, module_name in find:
        code = code.replace(source_code, f'__REQUIRE_MODULE__({module_name})')
    print(code)


if __name__ == '__main__':
    build("rkgui/init.lua")
