#!/usr/bin/env python3

import os
import io
import sys
import json
import argparse
import pathlib


def main():
    args = parse_args()
    generate_variables(args.path, args.output)


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("path", type=pathlib.Path)
    parser.add_argument("--output", type=argparse.FileType("w"), default=sys.stdout)
    return parser.parse_args()


def generate_variables(path: pathlib.Path, output: io.TextIOBase):
    with open(path) as fob:
        data = json.load(fob)

    rootpath = os.fspath(get_rootpath(data)) + os.sep

    print(f"ROOTPATH = {rootpath!r}", file=output)
    for dependency in data.get("dependencies", ()):
        name = dependency["name"]
        for (key, value) in dependency.items():
            if key != "name":
                variable = f"{name}_{key}".upper().replace(".", "")
                if variable[0].isdigit():
                    variable = f"X_{variable}"
                print(f"{variable} = {strip_rootpath(value, rootpath)!r}", file=output)


def get_rootpath(data) -> pathlib.Path:
    rootpaths = [pathlib.Path(d['rootpath']) for d in data.get("dependencies", ())]
    return pathlib.Path(os.path.commonpath(rootpaths))


def strip_rootpath(value, rootpath: str):
    if isinstance(value, str) and value.startswith(rootpath):
        return value[len(rootpath) :]

    if isinstance(value, list):
        return [strip_rootpath(x, rootpath) for x in value]

    return value


if __name__ == "__main__":
    main()
