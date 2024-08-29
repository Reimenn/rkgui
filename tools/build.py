import os
import re
from dataclasses import dataclass

if not os.path.exists("build"):
    os.mkdir('build')

FIND_REQUIRE_RE = re.compile("""(require ['"](.*?)['"])""")


def read_file(path: str, encoding: str = 'utf-8') -> str:
    with open(path, 'r', encoding=encoding) as f:
        return f.read()


module_cache: dict[str, 'LuaFile'] = {}


@dataclass
class LuaFile:
    module: str
    source_code: str
    requires: list[(str, str)]

    @staticmethod
    def read(lua_module: str) -> 'LuaFile | None':
        if lua_module not in module_cache:
            base_path = lua_module.replace('.', '/')
            path_options = [
                base_path + '.lua',
                base_path + '/init.lua'
            ]
            for path in path_options:
                if os.path.exists(path):
                    source_code = read_file(path)
                    module_cache[lua_module] = LuaFile(
                        module=lua_module,
                        source_code=source_code,
                        requires=FIND_REQUIRE_RE.findall(source_code),
                    )
                    break

        if lua_module in module_cache:
            return module_cache[lua_module]
        else:
            return None

    def parse_all_dependents(self):
        for require_code, require_module in self.requires:
            file = LuaFile.read(require_module)
            if file:
                file.parse_all_dependents()

    def as_build_module_func_code(self):
        code = self.source_code
        for require_code, require_module in self.requires:
            if require_module in module_cache:
                code = code.replace(
                    require_code, f"__BUILDED_MODULE__.REQUIRE('{require_module}')"
                )
        return code


if __name__ == '__main__':
    template = read_file(os.path.dirname(__file__) + r'\build_template.lua')
    rkgui = LuaFile.read("rkgui")
    rkgui.parse_all_dependents()
    read_file(__file__)
    with open('build/build.lua', 'w', encoding='utf-8') as f:
        f.write(template)
        for module in module_cache.values():
            f.write('\n')
            f.write(f"__BUILDED_MODULE__.MODULE['{module.module}'] = function()\n")
            f.write(module.as_build_module_func_code())
            f.write('\nend\n')

        f.write('\n')
        f.write('return __BUILDED_MODULE__.REQUIRE("rkgui")')
