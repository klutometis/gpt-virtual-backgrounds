# GPT Virtual Backgrounds

Generate a virtual background using GPT for spicing up your meetings a little
bit.

## Running

  1. Install [Bazelisk](https://github.com/bazelbuild/bazelisk).
  2. Run:

```
bazel run -c opt :background
```

Generates something like:

![Example background](./example-background.webp)

## Options

See full usage:

```
bazel run -c opt :background -- --help
USAGE: background [flags] args
flags:
flags:
  --model:  GPT model (default: 'dall-e-3')
  --output:  Where to write the image (default: '$HOME/background.webp')
  --prompt:  Prompt to use; takes precedence over --prompt_file (default: '')
  --prompt_file:  Prompt file to use (default: 'math-and-music.prompt')
  --size:  Size of the image (default: '1792x1024')
  -h,--help:  show this help (default: false)
```
