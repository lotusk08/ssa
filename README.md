# Static assets for stevehoang.com

## Introduction

Static assets (libraries/plugins) required by the website to run. Web fonts live in the parent repo under `assets/fonts/`. It provides the opportunity to choose self-host assets in production or development mode.

## Usage

- If you want to use these assets only in local development:

  Go to the root of your site and clone the assets as follows:

  ```console
  $ git submodule init
  $ git submodule update
  ```

  And then set your site configuration options:

  ```yml
  # _config.yml
  assets:
    self_host:
      enabled: true
      env: development
  ```

- If you expect the assets to be self-hosted when your website is published:

  Keep the `_config.yml` options as follows:

  ```yml
  # _config.yml
  assets:
    self_host:
      enabled: true
  ```

  And then update the GitHub Actions workflow in `.github/workflows/pages-deploy.yml`:

  ```diff
  steps:
    - name: Checkout
      uses: actions/checkout@v2
      with:
  +     submodules: true
  ```

## Versions

| Dependency                                               | Version   |
|:---------------------------------------------------------|:---------:|
| [GLightbox][glightbox]                                   | `3.3.1`   |
| [Mermaid][mermaid]                                       | `11.16.1` |
| [Simple-Jekyll-Search][simple-jekyll-search]             | `1.10.0`  |
| [Tocbot][tocbot]                                         | `4.36.8`  |
| [Chart.js][chartjs]                                      | `4.5.1`   |
| [Waline Client][waline]                                  | `3.15.2`  |
| Custom Emojis                                            | `0.0.1`   |


<!-- deps -->

[glightbox]: https://www.jsdelivr.com/package/npm/glightbox
[mermaid]: https://www.jsdelivr.com/package/npm/mermaid
[simple-jekyll-search]: https://www.jsdelivr.com/package/npm/simple-jekyll-search
[tocbot]: https://www.jsdelivr.com/package/npm/tocbot
[chartjs]: https://cdn.jsdelivr.net/npm/chart.js
[waline]: https://cdn.jsdelivr.net/npm/@waline/client
