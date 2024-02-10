# GPT Virtual Backgrounds

Generate some virtual backgrounds using GPT for spicing up your meetings a
little bit.

## Running

Run followingly:

  1. Install [Bazelisk](https://github.com/bazelbuild/bazelisk).
  2. Run:

```
bazel run -c opt :backgrounds
```

## Options

Change the model with the `--model` flag, which defaults to `dall-e-3`; also
change the prompt with `--prompt` (see default prompt in `prompt.default`). Size
can be modified with `--size` (default `1792x1024`); and output with `--output`
(default `$HOME/background.webp`).

Full usage:

```
$ bazel run -c opt :backgrounds -- --help
USAGE: backgrounds [flags] args
flags:
  --model:  GPT model (default: 'dall-e-3')
  --prompt:  Prompt to use (default: 'Can you create a simple virtual background which delights lovers of math and music? Shouldn'\''t be too busy.')
  --n:  How many to generate (default: 1)
  --size:  Size of the image (default: '1792x1024')
  --output:  Where to write the image (default: '/home/danenberg/background.webp')
  -h,--help:  show this help (default: false)
```
