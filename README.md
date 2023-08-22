# gh-action-build


Use it like this:

```yaml
name: Release

on:
  push:
    branches:
      - main

jobs:
  build-and-publish:
    runs-on: ubuntu-latest
    permissions:
      # IMPORTANT: this permission is mandatory for trusted publishing
      id-token: write
    steps:
    - name: Checkout
      uses: actions/checkout@v3
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.x'
    - name: Build
      uses: di/gh-action-build@main
    - name: Publish
      uses: pypa/gh-action-pypi-publish@master
      with:
        skip_existing: true
```
