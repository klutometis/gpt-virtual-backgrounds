# GPT Virtual Backgrounds

Generate some virtual backgrounds using GPT for spicing up your meetings a
little bit; run followingly:

  1. Install [Bazelisk](https://github.com/bazelbuild/bazelisk).
  2. Run `bazel run -c opt :backgrounds`.

Change the model with the `--model` flag, which defaults to `dall-e-3`; also
change the prompt with `--prompt` (see default prompt in `prompt.default`). Size
can be modified with `--size` (default `1792x1024`); and output with `--output`
(default `$HOME/background.webp`).
