VERSION = "1.0.0"
PLUGIN_NAME = "jqjson"

function init()
    if linter then
        linter.makeLinter(
            "jqjson",
            "json",
            "/home/rav/.local/bin/micro-json-lint",
            {"%f"},
            "%f:%l:%c: %m"
        )
    end
end
