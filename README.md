# A Language-aware, Coverage-based Evolutionary Fuzzer Bash Script Based on ISLa

This project demonstrates how to implement a simple evolutionary fuzzer around
[ISLa's](https://github.com/rindPHI/isla) `isla mutate` command, which mutates
program inputs preserving syntactical and semantic language features. To
demonstrate that in *essence*, it is really simple, we implemented the fuzzer in
Bash :smiley:

The main file containing all the fuzzer code is `fuzzer/fuzz.sh`. Test subjects
must be Python programs since we use the Python `coverage` module to obtain
coverage information.

To demonstrate that the fuzzer works, we added a test subject `render_rest.py`
exercising the `publish_cmdline` function from the Python `docutils` module, a
renderer for reStructuredText (reST). The `examples/rest/` directory contains
this test subject, together with a `requirements.txt` file for `docutils` and
the ISLa specifications for the reST language.

## Installation Instructions

This project requires Bash, Python >= 3.10, and the `json` executable from
https://github.com/trentm/json. Additionally, the Python libraries `isla-solver`
and `coverage` are required. The latter can be installed by writing `python3.10
-m pip install -r requirements.txt` in the project's main directory.

## Running the reST Example

Assuming that you followed the installation instructions, you can run the reST
example by typing the following commands into a terminal (assuming you `cd`ed
into the project's main directory):

```bash
cd examples/rest/
python3.10 -m pip install -r requirements.txt  # Only needed once!
./run_fuzzer.sh
```

Here's a part of example expected output:

    Initial input:
    ```
    4. !s
    
    ```
    
    
    =======================
    Round 1
    =======================
    
    New input:
    ```
    4. M!s
    
    ```
    
    NEW coverage, adding input to population
    
    =======================
    Round 2
    =======================
    
    New input:
    ```
    m:p
    ===
    
    ```
    
    NEW coverage, adding input to population
    
    =======================
    Round 3
    =======================
    
    New input:
    ```
    4. ye!
    7. 2
    
    ```
    
    NEW coverage, adding input to population
    
    =======================
    Round 4
    =======================
    
    New input:
    ```
    4. Vs!
    
    ```
    
    NO new coverage, discarding input

> :warning: This script is really just a demo of what can be done with `isla
> mutate` without putting in too much effort. It might happen that the fuzzer
> get's stuck in between; then simple press Ctrl-C and restart. Furthermore,
> I only added a partial spec for reST, which is why you might encounter
> messages such as "unexpected indentation" in between, which, however, don't
> harm the overall fuzzing campaign.

## Copyright

This project is released under the GNU General Public License v3.0 (see
[COPYING](COPYING)).

