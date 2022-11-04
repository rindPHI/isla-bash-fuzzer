from docutils.core import publish_cmdline
import os.path
import sys

inp_file = f"{os.path.dirname(__file__)}/input.rst"

sys.argv.append(inp_file)
publish_cmdline(writer_name='html')
