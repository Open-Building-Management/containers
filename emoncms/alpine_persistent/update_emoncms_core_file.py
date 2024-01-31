"""when using an emoncms container through a reverse proxy,
this script must be run at startup in order to modify core.php"""
lines = []
core_file = "/var/www/emoncms/core.php"
with open(core_file, 'r') as fp:
    lines = fp.readlines()
for i, line in enumerate(lines):
    if "    return $path;" in line:
        lines[i] = "    return $path.gethostname().'/';\n"
with open(core_file, 'w', encoding="utf-8") as fp:
    for line in lines:
        fp.write(line)
