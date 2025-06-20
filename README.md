# Static assets for stevehoang.com

## Introduction

Static assets (libraries/plugins/web-fonts) required by the website to run. It provides the opportunity to choose self-host assets in production or development mode.

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
| [Clipboard][clipboard]                                   | `2.0.11`  |
| [Day.js][dayjs]                                          | `1.11.13` |
| [GLightbox][glightbox]                                   | `3.3.0`   |
| [Loading-attribute-polyfill][loading-attribute-polyfill] | `2.1.1`   |
| [Mermaid][mermaid]                                       | `11.4.0`  |
| [Simple-Jekyll-Search][simple-jekyll-search]             | `1.10.0`  |
| [Tocbot][tocbot]                                         | `4.36.4`  |
| [Chart.js][chartjs]                                      | `4.4.9`   |
| [Waline Client][waline]                                  | `3.5.7`   |
| Custom Emojis                                            | `0.0.1`   |


<!-- deps -->

[clipboard]: https://www.jsdelivr.com/package/npm/clipboard
[dayjs]: https://www.jsdelivr.com/package/npm/dayjs
[loading-attribute-polyfill]: https://www.jsdelivr.com/package/npm/loading-attribute-polyfill
[glightbox]: https://www.jsdelivr.com/package/npm/glightbox
[mermaid]: https://www.jsdelivr.com/package/npm/mermaid
[simple-jekyll-search]: https://www.jsdelivr.com/package/npm/simple-jekyll-search
[tocbot]: https://www.jsdelivr.com/package/npm/tocbot
[chartjs]: https://cdn.jsdelivr.net/npm/chart.js
[waline]: https://cdn.jsdelivr.net/npm/@waline/client
