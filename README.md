# GPT Virtual Backgrounds

Generate a virtual background using GPT for spicing up your meetings a little
bit.

## Running

  1. Install [Bazelisk](https://github.com/bazelbuild/bazelisk).
  2. Run:

```
bazel run -c opt //bin:background -- --api_key=[OpenAI API key]
```

Generates something like:

![Example background](data/images/example-1.webp)

## Options

See full usage:

```
$ bazel run -c opt //bin:background -- --help
USAGE: bin/background [flags] args
flags:
  --api_key:  API key (takes precedence over --api_key_file)
    (default: '')
  --api_key_file:  API key file
    (default: 'data/keys/openai-api.key')
  --model:  GPT model
    (default: 'dall-e-3')
  --output:  Where to write the image
    (default: '/home/danenberg/background.webp')
  --prompt:  Prompt to use (takes precedence over --prompt_file)
    (default: '')
  --prompt_file:  Prompt file to use
    (default: 'data/prompts/math-and-music.prompt')
  --size:  Size of the image
    (default: '1792x1024')
  -h,--help:  show this help
    (default: false)
```
