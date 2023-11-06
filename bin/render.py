#!/usr/bin/env python3

import os
import os.path
import csv
from collections import OrderedDict
from jinja2 import Template


if __name__ == "__main__":

    entities = OrderedDict()

    for row in csv.DictReader(open("data/entities.csv")):
        entity = row["entity"]
        if entity not in entities:
            entities[entity] = {
                "name": row["name"],
                "entities": [],
                "document-url": row.get("document-url", ""),
            }
            if row["document-url"]:
                entities[entity]["img"] = "img/" + os.path.basename(row["document-url"]).replace(".pdf", ".png") 

        entities[entity]["entities"].append(row)

    with open('template.html') as f:
        template = Template(f.read())
        with open("docs/index.html", "w") as w:
            w.write(template.render({"entities": entities}))
