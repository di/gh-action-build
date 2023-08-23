import argparse
import glob
import os

import packaging.utils


parser = argparse.ArgumentParser()
parser.add_argument("--outdir")
args = parser.parse_args()

for path in glob.glob(os.path.join(args.outdir, "*.whl")):
    filename = os.path.basename(path)
    name, version, build, tags = packaging.utils.parse_wheel_filename(filename)
    for tag in tags:
        if tag.abi != "none" or tag.platform != "any":
            raise Exception("Non-pure wheels produced")
