import requests
import mwparserfromhell

def fetch_wikitext():
    url = "https://www.bg-wiki.com/api.php"
    params = {
        "action": "query",
        "prop": "revisions",
        "titles": "Fantastic_EXPs_and_Where_to_Find_Them",
        "rvslots": "*",
        "rvprop": "content",
        "formatversion": 2,
        "format": "json",
    }
    resp = requests.get(url, params=params)
    resp.raise_for_status()
    data = resp.json()
    page = data['query']['pages'][0]
    return page['revisions'][0]['slots']['main']['content']

def parse_exp_tables(wikitext):
    wikicode = mwparserfromhell.parse(wikitext)
    exp_entries = []

    for template in wikicode.filter_templates():
        if template.name.strip().lower() == "fantastic exp table":
            # Extract outer template fields
            zone = str(template.get("Zone").value).strip() if template.has("Zone") else ""
            camp_level = str(template.get("Camp Level").value).strip() if template.has("Camp Level") else ""

            # Combine all Fantastic EXP Row params
            rows_raw = ""
            for param in template.params:
                if param.name.strip().lower().startswith("fantastic exp row"):
                    rows_raw += str(param.value) + "\n"

            if rows_raw:
                rows_code = mwparserfromhell.parse(rows_raw)
                for row_template in rows_code.filter_templates():
                    if row_template.name.strip().lower() == "fantastic exp row":
                        camp_pos = ""
                        notes = ""
                        monsters = []

                        for key in ['Camp Position', 'Camp_Position', 'Camp position']:
                            if row_template.has(key):
                                camp_pos = str(row_template.get(key).value).strip()
                                break

                        for key in ['Minor Camp Note', 'Minor_Camp_Note', 'Minor camp note']:
                            if row_template.has(key):
                                notes = str(row_template.get(key).value).strip()
                                break

                        # Monster Row parsing
                        monster_rows_raw = ""
                        for param in row_template.params:
                            if param.name.strip().lower().startswith("fantastic exp monster row"):
                                monster_rows_raw += str(param.value) + "\n"

                        if monster_rows_raw:
                            monster_code = mwparserfromhell.parse(monster_rows_raw)
                            for monster_template in monster_code.filter_templates():
                                if monster_template.name.strip().lower() == "fantastic exp monster row":
                                    if monster_template.has("Monsters"):
                                        raw_monster = str(monster_template.get("Monsters").value).strip()
                                        # Remove the ':Category:' prefix and pipe if present
                                        if "{{!" in raw_monster:
                                            # It's using pipe-escape
                                            raw_monster = raw_monster.split("{{!}}")[-1].strip()
                                        elif "|" in raw_monster:
                                            raw_monster = raw_monster.split("|")[-1].strip()
                                        monsters.append(raw_monster)

                        exp_entries.append({
                            'zone': zone,
                            'camp_level': camp_level,
                            'camp_position': camp_pos,
                            'notes': notes,
                            'monsters': monsters,
                        })

    return exp_entries



def write_lua_table(data, filename="exp_data.lua"):
    def escape_lua_string(s):
        if s is None:
            return '""'
        s = s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')
        return f'"{s}"'

    def write_monster_list(monsters):
        return "{ " + ", ".join(escape_lua_string(m) for m in monsters) + " }"

    with open(filename, "w", encoding="utf-8") as f:
        f.write("return {\n")
        for entry in data:
            zone = escape_lua_string(entry.get("zone", ""))
            level = escape_lua_string(entry.get("camp_level", ""))
            camp = escape_lua_string(entry.get("camp_position", ""))
            notes = escape_lua_string(entry.get("notes", ""))
            monsters = write_monster_list(entry.get("monsters", []))
            f.write(f"    {{ zone = {zone}, camp_level = {level}, camp_position = {camp}, notes = {notes}, monsters = {monsters} }},\n")
        f.write("}\n")



def main():
    wikitext = fetch_wikitext()
    exp_data = parse_exp_tables(wikitext)
    for entry in exp_data:
        print(entry)
    write_lua_table(exp_data)

if __name__ == "__main__":
    main()
